#!/usr/bin/env groovy

/**
 * For more information about this library, please see: README.md
 * Variables that must be filled to this script work:
 * env.JiraKey
 * env.JiraSummary
 * env.JiraDescription
 * env.JiraIssueType
 */

def call(){
    try {
        JiraKey
        JiraSummary
        JiraDescription
        JiraIssueType
    } catch (e) {
        throw new RuntimeException("Please ensure the " +
            "'env.JiraKey' and " +
            "'env.JiraSummary' and " +
            "'env.JiraDescription' and " +
            "'env.JiraIssueType' " +
            "variables must be set on your main Jenkinsfile")
    }
    def issue = [fields: [ project: [key: "${JiraKey}"],
        summary: "${JiraSummary}",
        description: "${JiraDescription}",
        issuetype: [name: "${JiraIssueType}"]]]
    def newIssue = jiraNewIssue issue: issue, site: 'Jira Corporativo'
    echo newIssue.data.key
}
