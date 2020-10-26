#!/usr/bin/env groovy

/**
 * For more information about this library, please see: README.md
 * Variables that must be filled to this script work:
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
