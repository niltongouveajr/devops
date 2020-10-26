#!/usr/bin/env groovy

/**
 * For more information about this library, please see: README.md
 * Variables that must be filled to this script work:
 * env.BuildProject
 * env.BuildVersion
 * env.JiraKey
 * env.JiraJQL
 */

def call(){
    try {
        BuildProject
        BuildVersion
        JiraJQL
        JiraKey
        EmailRecipients
    } catch (e) {
        throw new RuntimeException("Please ensure the " +
            "'env.BuildProject' and " +
            "'env.BuildVersion' and " +
            "'env.JiraJQL' and " +
            "'env.EmailRecipients' and " +
            "'env.JiraKey' " +
            "variables must be set on your main Jenkinsfile")
    }
    def currDate = new Date()
    def JiraUrl = "https://jira.local"
    def newVersion = [
        name: "${BuildProject}.${BuildVersion}",
        archived: false,
        released: true,
        description: 'Release generated',
        project: "${JiraKey}"
        //releaseDate: currDate.format('dd-MM-yyyy')
    ]
    def newVersionResp = jiraNewVersion version: newVersion, site: 'Jira Corporativo'
    def versionId = newVersionResp.data.id
    newVersion.id = versionId
    echo "version: ${versionId}"
    echo "getting issues"
    // only Integrated issues
    def jiraSearch = jiraJqlSearch jql: JiraJQL, site: 'Jira Corporativo'
    def issues = jiraSearch.data.issues
    /*
    * You can find the correct transition id, inspecting the issues found on the
    * jqlQuery above and calling the getIssuesTransitions from an issue in the
    * desired state.
    *
    * See more in:
    * https://jenkinsci.github.io/jira-steps-plugin/steps/issue/jira_get_issue_transitions/
    */
    // "Integrate" transition (state)
    def transtionInput = [ transition: [ id: 201 ] ]
    def sout = new StringBuilder()
    sout.append("<html>\n")
    sout.append("<head>\n")
    sout.append("\t<style>\n")
    sout.append("\t\tbody {\n")
    sout.append("\t\t\tfont-family: 'sans-serif';\n")
    sout.append("\t\t}\n")
    sout.append("\t</style>\n")
    sout.append("</head>\n")
    sout.append("<body>\n")
    sout.append("\t<h1>A new version is created (${newVersion.name})</h1>\n")
    sout.append("\t<p>All issues contemplated in this version are: </p>\n")
    sout.append("\t<ul>\n")
    echo "Iterating in issues found (${issues.size()})"
    for (int i = 0; i < issues.size(); i++) {
        def issue = issues[i]
        def id = issue.id
        def updateIssue = [
            fields: [
                // custom field integrated version is: customfield_10401
                customfield_10201: [newVersion]
            ]
        ]
        // custom field for improvements
        jiraAddComment  idOrKey: id, comment: "A new version with this implementation was released. The version is: ${newVersion.name}", site: 'Jira Corporativo'
        jiraEditIssue idOrKey: id, issue: updateIssue, site: 'Jira Corporativo'
        try {
            jiraTransitionIssue idOrKey: id, input: transtionInput, site: 'Jira Corporativo'
        } catch (ex) {
            echo "Error transitioning issue, please check your jql filter (${ex})"
            echo "Available transitions are: "
            def transitions = jiraGetIssueTransitions idOrKey: id, site: 'Jira Corporativo'
            echo transitions.data.toString()
        }
        sout.append("\t\t<li style='font-size:10.5pt;font-family:\"Arial\",sans-serif;color:#333333'>")
        sout.append("\t\t\t<span>")
        sout.append("\t\t\t\t<a href=\"${JiraUrl}/issues/${issue.key}\" title=\"${issue.key}\">")
        sout.append("\t\t\t\t\t${issue.key}")
        sout.append("\t\t\t\t</a>")
        sout.append("\t\t\t</span>")
        sout.append("\t\t\t<span>")
        sout.append("\t\t\t\t<span class=ghx-inner>")
        sout.append("\t\t\t\t\t<span lang=EN-US> - ${issue.fields.summary}</span>")
        sout.append("\t\t\t\t</a>")
        sout.append("\t\t\t</span>")
        sout.append("\t\t</li>")
        //sout.append("\t\t<li>${issue.key} ${issue.fields.summary} - (<a href=\"${JiraUrl}/issues/${issue.key}\">${JiraUrl}/issues/${issue.key}</a>)</li>\n")
        echo "Issue details: "
        echo "${issue}"
    }
    sout.append("\t</ul>\n")
    sout.append("\t<h2>Version summary:</h2>\n")
    sout.append("\t<p>Jenkins build: <a href=\"${env.BUILD_URL}\">${env.BUILD_URL}</a></p>\n")
    sout.append("\t<br/>\n\n")
    sout.append("\t<p>Best regards,</p>\n")
    sout.append("\t<p>DevOps Team</p>\n")
    try {
        emailext (
            subject: "[${BuildProject}] New Version: ${newVersion}",
            body: sout.toString(),
            to: EmailRecipients,
            mimeType: 'text/html',
            replyTo: 'noreply@local',
            from: 'noreply@local'
        )
    } catch (ex) {
        echo "Unable to send email ${ex}"
    }
}
