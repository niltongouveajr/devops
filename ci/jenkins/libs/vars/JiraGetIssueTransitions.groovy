#!/usr/bin/env groovy

/**
 * For more information about this library, please see: https://gitlab.domain.local/shared/ci-utils/jenkins
 * Variables that need to be set for this lib to work correctly:
 * env.JiraIssue
 */

def call(){
    script {
        try {
            JiraIssue
        } catch (e) {
            throw new RuntimeException("Please ensure the " +
                "'env.JiraIssue' " +
                "variable must be set on your main Jenkinsfile")
        }
        withEnv(['JIRA_SITE=Jira Corporativo']) {
            def transitions = jiraGetIssueTransitions idOrKey: "${env.JiraIssue}"
            echo transitions.data.toString()
        }
    }
}
