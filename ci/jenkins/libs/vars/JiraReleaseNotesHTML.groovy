#!/usr/bin/env groovy

/**
 * For more information about this library, please see: https://gitlab.domain.local/shared/ci-utils/jenkins
 * Variables that need to be set for this lib to work correctly:
 * env.JiraReleaseProject
 * env.JiraReleaseFeatures
 * env.JiraReleaseBugs
 */

def call(){
    script {
        try {
            JiraReleaseProject
            JiraReleaseFeatures
            JiraReleaseBugs
        } catch (e) {
            throw new RuntimeException("Please ensure the " +
                "'env.JiraReleaseProject' " +
                "'env.JiraReleaseFeatures' " +
                "'env.JiraReleaseBugs' " +
                "variable must be set on your main Jenkinsfile")
        }
        withCredentials([usernamePassword(credentialsId: '00000000-0000-0000-0000-000000000000', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
            sh '''
                set +x
                JiraReleaseVersion="$(echo "${gitlabSourceBranch}" | sed "s|refs/tags/||g")"
                JiraReleaseDate=$(date '+%Y-%m-%d')
                echo -e '<h1 style="text-align: center;"><span style="color: #0000ff;">'"${JiraReleaseProject}"' Release Notes '"${JiraReleaseVersion}"'</span></h1>
<p style="text-align: center;"><span style="color: #3366ff;">Released date: '"${JiraReleaseDate}"'</span></p>
<p>&nbsp;</p>
<p style="text-align: center;"><span style="color: #000000;">Here are the latest features added to the system, including new features and fixed bugs.</span></p>
<p style="text-align: center;">&nbsp;</p>
<h2 style="text-align: center;"><strong>&nbsp;New Features</strong></h2>
<table style="101px; margin-left: auto; border-spacing: 0; margin-right: auto;" border="1" width="614">
<tbody>
<tr style="height: 35.5px;">
<td style="width: 299px; text-align: center; height: 35.5px;"><strong>Key</strong></td>
<td style="width: 299px; text-align: center; height: 35.5px;"><strong>Summary</strong></td>
</tr>' > ReleaseNotes.html
                JIRA_ISSUES=$(java -jar /srv/config/tools/jira-cli/8.3.0/lib/jira-cli-8.3.0.jar --server https://jira.domain.local --user ${USERNAME} --password ${PASSWORD} -a getIssueList --quiet --columns 1,21 --outputType text --jql \"${JiraReleaseFeatures}\" | grep -v \"^$\" | grep -v \" Key\" || true)
                if [[ -z "${JIRA_ISSUES}" ]]; then
                  JIRA_ISSUES="None  None" 
                fi
                while IFS= read -r JIRA_ISSUE ; do
                    JIRA_KEY=$(echo "${JIRA_ISSUE}" | awk -F "  " '{print $1}')
                    JIRA_SUMMARY=$(echo "${JIRA_ISSUE}" | awk -F "  " '{print $2}')
                    echo -e '</tr>
<tr style="height: 30px;">
<td style="width: 299px; text-align: center; height: 18px;">'"${JIRA_KEY}"'</td>
<td style="width: 299px; height: 18px; text-align: center;">'"${JIRA_SUMMARY}"'</td>
</tr>' >> ReleaseNotes.html
                done <<< "${JIRA_ISSUES}"
                echo -e '</tr>
</tbody>
</table>
<p style="text-align: center;">&nbsp;</p>
<h2 style="text-align: center;">Bugs Fixed</h2>
<table style="101px; margin-left: auto; border-spacing: 0; margin-right: auto;" border="1" width="614">
<tbody>
<tr style="height: 35.5px;">
<td style="width: 299px; text-align: center; height: 35.5px;"><strong>Key</strong></td>
<td style="width: 299px; text-align: center; height: 35.5px;"><strong>Summary</strong></td>
</tr>' >> ReleaseNotes.html
                JIRA_ISSUES=$(java -jar /srv/config/tools/jira-cli/8.3.0/lib/jira-cli-8.3.0.jar --server https://jira.domain.local --user ${USERNAME} --password ${PASSWORD} -a getIssueList --quiet --columns 1,21 --outputType text --jql \"${JiraReleaseBugs}\" | grep -v \"^$\" | grep -v \" Key\" || true)
                if [[ -z "${JIRA_ISSUES}" ]]; then
                  JIRA_ISSUES="None  None" 
                fi
                while IFS= read -r JIRA_ISSUE ; do
                    JIRA_KEY=$(echo "${JIRA_ISSUE}" | awk -F "  " '{print $1}')
                    JIRA_SUMMARY=$(echo "${JIRA_ISSUE}" | awk -F "  " '{print $2}')
                    echo -e '</tr>
<tr style="height: 30px;">
<td style="width: 299px; text-align: center; height: 18px;">'"${JIRA_KEY}"'</td>
<td style="width: 299px; height: 18px; text-align: center;">'"${JIRA_SUMMARY}"'</td>
</tr>' >> ReleaseNotes.html
                done <<< "${JIRA_ISSUES}"
                echo -e '</tr>
</tbody>
</table>
<p>&nbsp;</p>
<p style="text-align: center;">Any doubts please contact the developing team!</p>' >> ReleaseNotes.html
            '''
        }
    }
    script {
        env.HTMLAllowMissing = "true"
        env.HTMLReportDir = "."
        env.HTMLReportFiles = "ReleaseNotes.html"
        env.HTMLReportName = "Release Notes"
        HTMLPublisher()
        archiveArtifacts artifacts: '**/ReleaseNotes.html', allowEmptyArchive: true
    }
}
