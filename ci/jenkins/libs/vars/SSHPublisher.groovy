#!/usr/bin/env groovy

/**
 * For more information about this library, please see: https://gitlab.domain.local/shared/ci-utils/jenkins
 * Variables that need to be set for this lib to work correctly:
 * env.SSHPublisherConfigName
 * env.SSHPublisherExcludes
 * env.SSHPublisherExec
 * env.SSHPublisherRemoteDir
 * env.SSHPublisherRemovePrefix
 * env.SSHPublisherSourceFiles
 */

def call() {
    try {
        SSHPublisherConfigName
        SSHPublisherExcludes
        SSHPublisherExec
        SSHPublisherRemoteDir
        SSHPublisherRemovePrefix
        SSHPublisherSourceFiles
    } catch (e) {
        throw new RuntimeException("Please ensure the " +
            "'env.SSHPublisherConfigName' and " +
            "'env.SSHPublisherExcludes' and " +
            "'env.SSHPublisherExec' and " +
            "'env.SSHPublisherRemoteDir' and " +
            "'env.SSHPublisherRemovePrefix' and " +
            "'env.SSHPublisherSourceFiles' " +
            "variable must be set on your main Jenkinsfile")
    }
    sshPublisher continueOnError: false, failOnError: true, publishers: [
        sshPublisherDesc(
            configName: "${env.SSHPublisherConfigName}", 
            transfers: [sshTransfer(
                cleanRemote: true, 
                excludes: "${env.SSHPublisherExcludes}", 
                execCommand: "${env.SSHPublisherExec}", 
                execTimeout: 120000, 
                flatten: false, 
                makeEmptyDirs: false, 
                noDefaultExcludes: false, 
                patternSeparator: '[, ]+', 
                remoteDirectory: "${env.SSHPublisherRemoteDir}", 
                remoteDirectorySDF: false, 
                removePrefix: "${env.SSHPublisherRemovePrefix}", 
                sourceFiles: "${env.SSHPublisherSourceFiles}"
            )],
            usePromotionTimestamp: false,
            useWorkspaceInPromotion: false,
            verbose: false
        )
    ]    
}
