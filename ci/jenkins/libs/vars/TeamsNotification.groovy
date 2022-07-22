#!/usr/bin/env groovy

/**
 * For more information about this library, please see: https://gitlab.domain.local/shared/ci-utils/jenkins
 * Variables that need to be set for this lib to work correctly:
 * env.TeamsWebHook
 */

def call() {
    try {
        TeamsWebHook
    } catch (e) {
        throw new RuntimeException("Please ensure the " +
            "'env.TeamsWebHook' " +
            "variable is defined on your main Jenkinsfile")
    }
    BuildStatus = currentBuild.result
    script {
        if (currentBuild.currentResult == 'FAILURE') {
            ThemeColor = 'FF0B00'
        }
        if (currentBuild.currentResult == 'UNSTABLE') {
            ThemeColor = 'FBF70C'
        }
        if (currentBuild.currentResult == 'SUCCESS') {
            ThemeColor = '35B535'
        }
    }
    Subject = "[VNT.DevOps] ${env.JOB_NAME} (#${env.BUILD_NUMBER}) ~ ${BuildStatus}"
    Message = "Check console output at <a href=\"${env.BUILD_URL}console\">${env.BUILD_URL}</a>"
    if (isUnix()) {
        sh("curl --silent -k -d \"{'@context': 'http://schema.org/extensions','@type': 'MessageCard','themeColor': '${ThemeColor}','title': '${Subject}','text': '${Message}'}\" -H \"Content-Type: application/json\" -X POST ${TeamsWebHook}")
    } else {
        EnvVarsDefaultWin()
        bat("curl --silent -k -d \"{'@context': 'http://schema.org/extensions','@type': 'MessageCard','themeColor': '${ThemeColor}','title': '${Subject}','text': '${Message}'}\" -H \"Content-Type: application/json\" -X POST ${TeamsWebHook}")
    }
}
