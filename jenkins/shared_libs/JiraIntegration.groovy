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
    def TagName = "${gitlabBranch}"
    TagName = TagName.replaceAll "refs/tags/", ""
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
    def EmailContent = """
        <!doctype html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width">
            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
            <title>Ferramentas de Suporte ao Desenvolvimento</title>

            <style>
                a {
                    color: #ED1B66;
                }
            </style>

        </head>

        <body bgcolor="#f6f6f6" link="#ED1B66" vlink="#ED1B66">

            <table border="0" cellpadding="0" cellspacing="0" width="100%" style="border: 1px solid lightgray; background-color: #FFF;" align="center">
            <tr>
                <td class="header-section" style="border-bottom: 1px solid #999999;background-image: linear-gradient(to right, #532d8c 0%, #ed1b66 100%);background-color: #542D8C;background-size:contain;height: 80px;width: 105%;vertical-align: middle;padding-top: 10px;padding-left: 22px;">
                    <img src="cid:logo_header.png">
                </td>
            </tr>
            <tr>
                <td >
                    <table style="margin: 25px;">
                        <tr>
                            <td>
                                <h2 style="font-family: verdana, sans-serif;color: #888;font-weight: bolder;font-size: 14pt;margin: 0;padding: 0;margin:0;mso-line-height-rule:exactly;">
                                    DevOps
                                </h2>
                                <h3 style="font-family: verdana, sans-serif;color: #2E2E2E;font-weight: bolder;font-size: 32pt;margin: 0;padding: 0;margin-bottom: 30px;margin:0;mso-line-height-rule:exactly;">
                                    Jenkins
                                </h3>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <p style="font-family: verdana, helvetica, sans-serif; margin-top: 0px;">
                                    <br>
                                    Hello!
                                    <br>
                                    <br>
                                    A new release for <b><span style="color:#ED1B66">${env.JOB_NAME}</span></b> has been generated. More details about the new release <b><span style="color:#ED1B66">${TagName}</span></b> can be found at:
                                    <br>
                                    <br>
                                    <b><a href="${env.BUILD_URL}console" style="text-decoration:none;"><span style="color:#ED1B66"><u>${env.BUILD_URL}console</u></a></span></b>
                                    <br>
                                    <br>
                                    You are receiving this email from Jenkins because you're either on a notification list or you commited some code to a project being built by Jenkins. If you do not want to receive this email, please let us know.
                                </p>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td>
                    <table border="0" cellpadding="0" cellspacing="0" width="100%" style="margin: 20px;magin-top: 0px;width: 100%;font-family: verdana, sans-serif;">
                        <tbody>
                            <tr>
                                <td valign="top" width="100%" style="padding: 8px;text-align: left;">
    """

    def EmailContent2 = """
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </td>
            </tr>
            <tr>
                <td>
                    <table border="0" cellpadding="0" cellspacing="0" width="100%" style="margin: 20px;magin-top: 0px;width: 100%;font-family: verdana, sans-serif;">
                        <tbody>
                            <tr>
                                <td valign="top" width="90" style="padding: 8px;text-align: left;">
                                    <img src="cid:logo_footer.png"
                                        width="90" height="70" alt="Venturus" style="border: 0;max-width: 100%;height: auto;">
                                    <br>
                                </td>
                                <td valign="top" style="padding: 8px;text-align: left;">
                                    <span style="font-family:Helvetica,Calibri,Candara,Segoe,Segoe UI,Optima,verdana,sans-serif;">
                                        <span style="color:#181818; font-size: 14px; line-height: 18px;">
                                            <b style="font-weight: bold;">Jenkins</b>
                                        </span>
                                        <br>
                                        <span style="color:#e81a67; font-size: 12px;">DEVOPS TEAM</span>
                                        <br>
                                        <a style="color: #999999;font-size: 12px;background-color: transparent;transition: color 0.2s ease;" href="https://devops.local"
                                            target="_blank">
                                            <b style="font-weight: bold;">local</b>
                                        </a>
                                        <br>
                                        <span style="color:#BBBBBB; font-size: 9px;">DEVELOPING THE FUTURE</span>
                                    </span>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </td>
            </tr>
        </table>
        </body>
        </html>
    """
    def sout = new StringBuilder()
    // sout.append("<html>\n")
    // sout.append("<head>\n")
    // sout.append("\t<style>\n")
    // sout.append("\t\tbody {\n")
    // sout.append("\t\t\tfont-family: 'sans-serif';\n")
    // sout.append("\t\t}\n")
    // sout.append("\t</style>\n")
    // sout.append("</head>\n")
    // sout.append("<body>\n")
    // sout.append("\t<h1>A new version is created (${newVersion.name})</h1>\n")
    sout.append(EmailContent)
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
    sout.append(EmailContent2)
    if (isUnix()) {
        sh 'wget -q https://devops.local/downloads/others/email/logo_header.png -O logo_header.png'
        sh 'wget -q https://devops.local/downloads/others/email/logo_footer.png -O logo_footer.png'
    } else {
        EnvVarsDefaultWin()
        bat 'wget -q https://devops.local/downloads/others/email/logo_header.png -O logo_header.png'
        bat 'wget -q https://devops.local/downloads/others/email/logo_footer.png -O logo_footer.png'
    }
    try {
        // emailext (
        //     subject: "[${BuildProject}] New Version: ${newVersion}",
        //     body: sout.toString(),
        //     to: EmailRecipients,
        //     mimeType: 'text/html',
        //     replyTo: 'noreply@local',
        //     from: 'noreply@local'
        // )
        emailext (
            attachmentsPattern: "logo_header.png,logo_footer.png",
            to: "\$DEFAULT_RECIPIENTS,${EmailRecipients}",
            replyTo: 'noreply@local',
            subject: "[DevOps] ${env.JOB_NAME} (#${env.BUILD_NUMBER}) ~ New Release! ",
            body: sout.toString(),
            mimeType: 'text/html',
            recipientProviders: [
    //          [$class: 'DevelopersRecipientProvider'],
                [$class: 'CulpritsRecipientProvider'],
                [$class: 'RequesterRecipientProvider']
            ]
        )
    } catch (ex) {
        echo "Unable to send email ${ex}"
    }
}
