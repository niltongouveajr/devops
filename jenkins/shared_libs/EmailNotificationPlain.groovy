#!/usr/bin/env groovy

/**
 * For more information about this library, please see: README.md
 * Variables that must be filled to this script work:
 * env.EmailRecipients
 */

def call() {
    try {
        EmailRecipients
    } catch (e) {
        throw new RuntimeException("Please ensure the " +
            "'env.EmailRecipients' " +
            "variable is defined on your main Jenkinsfile")
    }
    emailext (
        to: "\$DEFAULT_RECIPIENTS,${EmailRecipients}",
        replyTo: 'noreply@local',
        subject: '$DEFAULT_SUBJECT',
        body: '$DEFAULT_CONTENT',
        mimeType: 'text/html',
        recipientProviders: [
//          [$class: 'DevelopersRecipientProvider'],
            [$class: 'CulpritsRecipientProvider'],
            [$class: 'RequesterRecipientProvider']
        ]
    )
}
