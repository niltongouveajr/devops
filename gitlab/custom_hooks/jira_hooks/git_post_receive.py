#!/usr/bin/env python

__author__  = "scmenthusiast@gmail.com"
__version__ = "1.0"

from jira_commit_lib import JiraCommitHook
from jira_commit_lib import ScmActivity
from json import load, loads, dumps
from datetime import datetime
import argparse
import sys
import os

class GitPostReceiveHook(object):

    def __init__(self, config="git_cfg.json"):
        """
        __init__(). prepares or initiates configuration file
        :return: None
        """

        self.config_file = os.path.join(os.path.dirname(__file__), config)

        if self.config_file and os.path.exists(self.config_file):
            try:
                config = load(open(self.config_file))

                self.git_web = config.get("git.web")
                self.git_cmd = config.get("git.cmd.path")
                if not os.path.exists(self.git_cmd):
                    self.git_cmd = "git"

                self.jch = JiraCommitHook(config)

                self.file_status = {
                    "D" : "DEL",
                    "U" : "MODIFY",
                    "A" : "ADD",
                    "M" : "MODIFY"
                }

            except ValueError, e:
                print (e)
                exit(1)
        else:
            print ("Config file ({0}) not exists!".format(config))
            exit(1)

    def get_git_change(self, revision, refname):
        """
        get_git_change(). get scm change activity for given revision
        :param revision: Git repository path
        :param refname: Git ref name
        :return: object
        """

        changeset = ScmActivity()
        changeset.changeId = self.jch.command_output("{0} rev-parse --short {1}".format(self.git_cmd, revision))        
        changeset.changeBranch = refname
        changeset.changeMessage = self.jch.command_output("{0} show -s --pretty=format:\"%B\" {1}".format(self.git_cmd, revision))
        changeset.changeAuthor = self.jch.command_output("{0} show -s --pretty=format:\"%ce\" {1}".format(self.git_cmd, revision))

        git_date_time = self.jch.command_output("{0} show -s --pretty=format:\"%ct\" {1}".format(self.git_cmd, revision))

        changeset.changeDate = datetime.fromtimestamp(int(git_date_time)).strftime('%Y-%m-%d %H:%M:%S')

        changed_output = self.jch.command_output("{0} show --pretty=\"format:\" --name-status {1}".format(self.git_cmd, revision))

        change_files = []
        for my_file in changed_output.split("\n"):
            file_action, file_name = my_file.strip().split()

            if self.file_status.get(file_action):
                file_action = self.file_status.get(file_action)

            file_dict = {
                "fileName" : file_name,
                "fileAction" : file_action
            }
            change_files.append(file_dict)

        changeset.changeFiles = change_files

        return changeset

    def run(self, oldrev, newrev, refname):
        """
        run(). executes the jira update for the given change-set
        :param repos: Subversion repository path
        :param revision: Subversion revision
        :return: None
        """

        git_revision_list = self.jch.command_output("{0} rev-list {1}...{2}".format(self.git_cmd, oldrev, newrev))

        for revision in git_revision_list.split("\n"):

            git_changeset = self.get_git_change(revision.strip(), refname)

            if git_changeset:
                matched_issue_keys = self.jch.pattern_validate(git_changeset.changeMessage)
                # Preferred format: ChangeType_Repository Name e.g. git_ccx
                git_changeset.changeType = "{0}_{1}".format("git", os.path.basename(os.getcwd()).replace("-","_").replace(".git",""))
                #git_changeset.changeLink = self.git_web.format(os.path.basename(os.getcwd()), revision.strip())
                git_changeset.changeLink = self.git_web.format(os.path.abspath(os.getcwd()).replace("/var/opt/gitlab/git-data/repositories/","").replace(".git",""), revision.strip())

                '''print dumps(git_changeset.__dict__, indent=4)
                print matched_issue_keys'''

                if len(matched_issue_keys.keys()) > 0:
                    self.jch.jira_update(git_changeset, matched_issue_keys.keys())
                    'self.jch.jira_update(p4_change, matched_issue_keys.keys(), 1)' # to update existing activity


def main():
    """
    main(). parses sys arguments for execution
    :param: None
    :return: None
    """

    parser = argparse.ArgumentParser(description='SCM Activity GIT Post Receive Hook Execution Script')
    parser.add_argument("--config", help='Required config')
    parser.add_argument("--oldrev", help='Required oldrev', required=True)
    parser.add_argument("--newrev", help='Required newrev', required=True)
    parser.add_argument("--refname", help='Required refname', required=True)

    args = parser.parse_args()

    # oldrev, newrev, refname = sys.stdin.read().split()

    if args.oldrev and args.newrev and args.refname:
        g = GitPostReceiveHook(args.config)
        g.run(args.oldrev, args.newrev, args.refname)
    else:
        print "[usage] post-receive oldrev newrev refname"
        sys.exit(1)


if __name__ == '__main__':
    main()
