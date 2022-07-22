#!/usr/bin/env groovy

/**
 * For more information about this library, please see: https://gitlab.domain.local/shared/ci-utils/jenkins
 * Variables that need to be set for this lib to work correctly:
 * env.XrayEndPointName 
 * env.XrayImportFilePath
 * env.XrayJiraKey
 * env.XrayRevision
 * env.XrayTestEnvironments
 */

def call() {
    try {
        XrayEndPointName
        XrayImportFilePath
        XrayJiraKey
        XrayRevision
        XrayTestEnvironments
    } catch (e) {
        throw new RuntimeException("Please ensure the " +
            "'env.XrayEndPointName' and " +
            "'env.XrayImportFilePath' and " +
            "'env.XrayJiraKey' and " +
            "'env.XrayRevision' and " +
            "'env.XrayTestEnvironments' " +
            "variable must be set on your main Jenkinsfile")
    }
    step(
        [$class: 'XrayImportBuilder',
            endpointName: "${env.XrayEndPointName}",
            importFilePath: "${env.XrayImportFilePath}",
            importToSameExecution: 'true',
            projectKey: "${env.XrayJiraKey}",
            revision: "${XrayRevision}",
            testEnvironments: "${XrayTestEnvironments}",
            serverInstance: '66f78a56-187b-4cd9-a729-edb56e3ca841'
        ]
    )
}
