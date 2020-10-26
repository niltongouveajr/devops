#!/usr/bin/env python

__author__  = "scmenthusiast@gmail.com"
__version__ = "1.0"

from json import loads, dumps
from datetime import datetime
import requests
import subprocess
import os
import re
import tzlocal
import pytz


class ScmActivity(object):

    def __init__(self):
        """
        __init__(). scm changeset object with getters and setters
        :return: None
        """

        self.issueKey = None
        self.changeId = None
        self.changeType = None
        self.changeDate = None
        self.changeAuthor = None
        self.changeBranch = None
        self.changeStatus = None
        self.changeTag = None
        self.changeLink = None
        self.changeMessage = None
        self.changeFiles = None
        self.changeUpdate = None
        self.notifyEmail = None
        self.notifyAs = None


class JiraCommitHook(object):

    def __init__(self, config):
        """
        __init__(). prepares or initiates configuration object
        :param config: config object
        :return: None
        """

        self.config = config
        self.jira_server_url = config.get("jira.server.url")
        self.jira_auth_token = config.get("jira.auth.token")
        self.jira_notify = config.get("jira.notify.email")
        self.jira_notify_as = config.get("jira.notify.email.as")

    def jira_update(self, scm_activity, issue_keys, change_update=0):
        """
        jira_update(). It updates change-set details for give issue keys on JIRA
        :param scm_activity: change set dictionary object
        :param issue_keys: change issue keys
        :param change_update: update existing scm activity or not
        :return: None
        """

        with requests.Session() as session:

            session.headers.update({'Content-Type': 'application/json'})
            session.headers.update({"Authorization": "Basic {0}".format(self.jira_auth_token)})

            issue_exists_list = []

            'Verify issues'

            for v_key in issue_keys:
                if v_key.lower() == "none":
                    continue

                'print "[Info] processing Issue query {0} ...".format(v_key)'
                jira_rest_url = self.jira_server_url + r"/rest/api/2/issue/" + v_key

                response = session.get(jira_rest_url)

                if response.status_code == 200:
                    issue = response.json()
                    if issue.get("key"):
                        issue_exists_list.append(v_key)
                elif response.status_code == 403:
                    print "[Error] Invalid JIRA token - 403"
                else:
                    print "[Error] {0} Issue Does Not Exist - {1}".format(v_key, response.text)

            'Update issues'

            jira_rest_url = self.jira_server_url + "/rest/scmactivity/1.0/changeset/activity"

            if type(scm_activity) is ScmActivity:

                for e_key in issue_exists_list:

                    'print "[Info] processing Issue update -> key:{0}".format(e_key)'

                    scm_activity.issueKey = e_key
                    scm_activity.changeDate = self.get_jira_utc_datetime(scm_activity.changeDate)
                    scm_activity.notifyEmail = self.jira_notify

                    if change_update == 1:
                        scm_activity.changeUpdate = "true"

                    if self.jira_notify_as and self.jira_notify_as != "":
                        scm_activity.notifyAs = self.jira_notify_as

                    'print ( dumps(scm_activity.__dict__, indent=4) )'

                    response = session.post(jira_rest_url, json=scm_activity.__dict__)

                    if response.status_code == 201:
                        print "{0}".format(response.json().get("message"))
                    elif response.status_code == 403:
                        print "[Error] Invalid JIRA token - 403"
                    elif response.status_code == 400:
                        print "{0}".format(response.json().get("message"))
                    else:
                        print response.text

            else:
                print "[Error] Type is not Scm Activity type."

    def jira_pre_validate(self, issue_keys):
        """
        jira_pre_validate(). It validates issue keys for give issue keys on JIRA in pre commit hook
        :param issue_keys: change issue keys
        :return: None
        """

        with requests.Session() as session:

            session.headers.update({"Authorization": "Basic {0}".format(self.jira_auth_token)})

            index = 0
            for v_key in issue_keys:
                if v_key.lower() == "none":
                    index += 1
                    continue

                'print "[Info] processing Issue {0} ...".format(v_key)'
                jira_rest_url = self.jira_server_url + r"/rest/api/2/issue/" + v_key

                response = session.get(jira_rest_url)

                if response.status_code == 200:
                    issue = response.json()

                    if issue.get("key"):
                        'print "[Info] issue {0} is valid.".format(v_key)'
                        index += 1
                    else:
                        print "[Warn] issue {0} not exists.".format(v_key)
                else:
                    print "[Warn] {0} Issue Does Not Exist - {1}".format(v_key, response.text)

            if index == 0:
                print "[Error] *** Required at-least one valid JIRA Issue ID. e.g. [JIRA DUMMY-5]."
                exit(1)

    def get_jira_utc_datetime(self, raw_datetime):
        """
        get_jira_datetime(). gives jira application date time for the given date time
        :param raw_datetime: change date time
        :return: str
        """

        jira_timezone = pytz.timezone("UTC")
        hook_timezone = tzlocal.get_localzone()
        date_fmt = "%Y-%m-%d %H:%M:%S"
        hook_parse_dt_str =  datetime.strptime(raw_datetime, date_fmt)
        hook_local_dt = hook_timezone.localize(hook_parse_dt_str)
        jira_local_dt = hook_local_dt.astimezone(jira_timezone)

        return jira_local_dt.strftime(date_fmt)

    def pattern_validate(self, message):
        """
        pattern_validate(). pattern matches the given message content
        :param message: change message
        :return: list
        """

        issue_patterns = self.config.get("jira.issue.patterns")
        issue_keys = {}

        for pattern in issue_patterns:
            for match in re.finditer(pattern, message, re.IGNORECASE):
                'logging("{0}".format(match.group()))'

                key = re.sub("[\[()\]]|JIRA\s+", "", match.group(), flags=re.IGNORECASE)

                arg = re.search("fix|resolve", key, re.IGNORECASE)

                if arg:
                    confirm_key = re.sub("fix|resolve", "", key, flags=re.IGNORECASE)
                    issue_keys[confirm_key.strip()] = arg.group().strip()
                else:
                    'print "[Info] key: {0} -> arg: none".format(key))'
                    issue_keys[key.strip()] = None

        return issue_keys

    def command_output(self, cmd):
        """
        command_output(). It get command out put for give cmd
        :param cmd: command
        :return: None
        """

        p = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True)

        (output, err) = p.communicate()

        status = p.wait()

        if status == 0:
            return output.strip()
        else:
            print err
            exit(1)
