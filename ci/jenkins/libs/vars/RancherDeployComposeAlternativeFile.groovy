#!/usr/bin/env groovy

/**
 * For more information about this library, please see: https://gitlab.domain.local/shared/ci-utils/jenkins
 * Variables that need to be set for this lib to work correctly:
 * env.RancherUser
 * env.RancherToken
 * env.RancherCluster
 * env.RancherServer
 * env.RancherNamespace
 * env.RancherSecret
 * env.RancherComposeFile
 */

def call(){
     try {
        RancherUser
        RancherToken
        RancherCluster
        RancherServer
        RancherNamespace
        RancherSecret
        RancherComposeFile

    } catch (e) {
        throw new RuntimeException("Please ensure the " +
            "'env.RancherUser' and " +
            "'env.RancherToken' and " +
            "'env.RancherCluster' and " +
            "'env.RancherServer' and " +
            "'env.RancherNamespace' and " +
            "'env.RancherSecret' and " +
            "'env.RancherComposeFile' " +
            "variables must be set on your main Jenkinsfile")
    }
    sh "kubectl config set-credentials \"${RancherUser}\" --token \"${RancherToken}\""
    sh "kubectl config set-cluster \"${RancherCluster}\" --insecure-skip-tls-verify=\"true\" --server=\"${RancherServer}\""
    sh "kubectl config set-context \"${RancherNamespace}\" --user=\"${RancherUser}\" --cluster=\"${RancherCluster}\""
    sh "kubectl config use-context \"${RancherNamespace}\""
    sh "kubectl patch serviceaccount default -p '{\"imagePullSecrets\": [{\"name\": \"${RancherSecret}\"}]}' --namespace=${RancherNamespace} || true"
    sh "rm -rf tmp"
    sh "mkdir tmp"
    dir('tmp') {
        sh "kompose convert -f ../${RancherComposeFile}"
        sh "kubectl delete -f ./ --namespace=${RancherNamespace} || true"
	    sh "kubectl apply -f ./ --namespace=${RancherNamespace}"
    }
}
