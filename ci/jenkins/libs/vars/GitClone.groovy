#!/usr/bin/env groovy

/**
 * For more information about this library, please see: https://gitlab.domain.local/shared/ci-utils/jenkins
 * Variables that need to be set for this lib to work correctly:
 *  env.GitURL
 *  env.GitCredentials
 */

def call(){
    try {
        GitURL
        GitCredentials
    } catch (e) {
        throw new RuntimeException("Please ensure the " +
            "'env.GitURL' and " +
            "'env.GitCredentials' " +
            "variables must be set on your main Jenkinsfile")
    }
    // Block merge request while pipeline is broken
    updateGitlabCommitStatus name: 'build', state: 'pending'
    checkout scm: [
        $class: 'GitSCM',
        userRemoteConfigs: [[
            url: "${GitURL}",
            credentialsId: "${GitCredentials}"
        ]],
        branches: [[
            name: gitBranchClone()
        ]]
    ], poll: false
}

def gitBranchClone() {
    def branch = _gitlabBranch()
    return branch
}

def _gitlabBranch() {
    if (_gitlabSourceBranch() == null) {
        try {
            return gitlabBranch
        } catch (ex) {
            //return 'master'
            return 'development'
        }
    } else {
        return _gitlabSourceBranch()
    }
}

def _gitlabSourceBranch() {
    try {
        return gitlabSourceBranch
    } catch (ex) {
        return null
    }
}
