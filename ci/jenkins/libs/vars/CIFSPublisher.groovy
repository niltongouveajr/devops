#!/usr/bin/env groovy

/**
 * For more information about this library, please see: https://gitlab.domain.local/shared/ci-utils/jenkins
 * Variables that need to be set for this lib to work correctly:
 * env.CIFSPublisherConfigName
 * env.CIFSPublisherExcludes
 * env.CIFSPublisherRemoteDir
 * env.CIFSPublisherRemovePrefix
 * env.CIFSPublisherSourceFiles
 */

def call() {
    try {
        CIFSPublisherConfigName
        CIFSPublisherExcludes
        CIFSPublisherRemoteDir
        CIFSPublisherRemovePrefix
        CIFSPublisherSourceFiles
    } catch (e) {
        throw new RuntimeException("Please ensure the " +
            "'env.CIFSPublisherConfigName' and " +
            "'env.CIFSPublisherExcludes' and " +
            "'env.CIFSPublisherRemoteDir' and " +
            "'env.CIFSPublisherRemovePrefix' and " +
            "'env.CIFSPublisherSourceFiles' " +
            "variable must be set on your main Jenkinsfile")
    }
    cifsPublisher alwaysPublishFromMaster: false, continueOnError: false, failOnError: false, publishers: [[
        configName: "${env.CIFSPublisherConfigName}", 
        transfers: [[cleanRemote: true,
            excludes: "${env.CIFSPublisherExcludes}",
            flatten: false,
            makeEmptyDirs: false,
            noDefaultExcludes: false,
            patternSeparator: '/',
            remoteDirectory: "${env.CIFSPublisherRemoteDir}",
            remoteDirectorySDF: false,
            removePrefix: "${env.CIFSPublisherRemovePrefix}",
            sourceFiles: "${env.CIFSPublisherSourceFiles}" ]],
            usePromotionTimestamp: false,
            useWorkspaceInPromotion: false,
            verbose: true
        ]]
}
