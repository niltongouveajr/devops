#!/usr/bin/env groovy

/**
 * For more information about this library, please see: https://gitlab.domain.local/shared/ci-utils/jenkins
 * Variables that need to be set for this lib to work correctly:
 * env.HTMLAllowMissing
 * env.HTMLReportDir
 * env.HTMLReportFiles
 * env.HTMLReportName
 */

def call() {
    try {
        HTMLAllowMissing
        HTMLReportDir
        HTMLReportFiles
        HTMLReportName
    } catch (e) {
        throw new RuntimeException("Please ensure the " +
            "'env.HTMLAllowMissing' and " +
            "'env.HTMLReportDir' and " +
            "'env.HTMLReportFiles' and " +
            "'env.HTMLReportName' " +
            "variable must be set on your main Jenkinsfile")
    }
    publishHTML target: [
        allowMissing: "${env.HTMLAllowMissing}",
        alwaysLinkToLastBuild: false,
        keepAll: true,
        reportDir: "${env.HTMLReportDir}",
        reportFiles: "${env.HTMLReportFiles}",
        reportName: "${env.HTMLReportName}"
    ]
}
