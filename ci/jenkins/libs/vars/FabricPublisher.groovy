#!/usr/bin/env groovy

/**
 * For more information about this library, please see: https://gitlab.domain.local/shared/ci-utils/jenkins
 * Variables that need to be set for this lib to work correctly:
 * env.FabricAPIKey
 * env.FabricAPKPath
 * env.FabricBuildSecret
 * env.FabricOrganization
 * env.FabricTestersEmails
 */

def call() {
    try {
        FabricAPIKey
        FabricAPKPath
        FabricBuildSecret
        FabricOrganization
        FabricTestersEmails
    } catch (e) {
        throw new RuntimeException("Please ensure the " +
            "'env.FabricAPIKey' and " +
            "'env.FabricAPKPath' and " +
            "'env.FabricBuildSecret' and " +
            "'env.FabricOrganization' and " +
            "'env.FabricTestersEmails' " +
            "variable must be set on your main Jenkinsfile")
    }
    step(
        [$class: 'FabricBetaPublisher',
            apiKey: "${env.FabricAPIKey}",
            apkPath: "${env.FabricAPKPath}",
            buildSecret: "${env.FabricBuildSecret}",
            organization: "${env.FabricOrganization}",
            notifyTestersType: 'NOTIFY_TESTERS_EMAILS',
            testersEmails:"${env.FabricTestersEmails}",
            useAntStyleInclude: true
        ]
    )
}
