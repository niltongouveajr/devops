#!/usr/bin/env groovy

/**
 * For more information about this library, please see: https://gitlab.domain.local/shared/ci-utils/jenkins
 * Variables that need to be set for this lib to work correctly:
 * env.RancherUser
 * env.RancherToken
 * env.RancherServer
 * env.RancherCluster
 * env.RancherNamespace
 * env.RancherSecret
 * env.RancherDeployment
 * env.RancherComposeFile
 */

def call(){
     try {
        RancherUser
        RancherToken
        RancherServer
        RancherCluster
        RancherNamespace
        RancherSecret
        
    } catch (e) {
        throw new RuntimeException("Please ensure the " +
            "'env.RancherUser' and " +
            "'env.RancherToken' and " +
            "'env.RancherServer' and " +
            "'env.RancherCluster' and " +
            "'env.RancherNamespace' and " +
            "'env.RancherSecret'  " +
            "'env.RancherComposeFile' " +
            "variables must be set on your main Jenkinsfile")
    }
    sh "kubectl config set-credentials \"${RancherUser}\" --token \"${RancherToken}\""
    sh "kubectl config set-cluster \"${RancherCluster}\" --insecure-skip-tls-verify=\"true\" --server=\"${RancherServer}\""
    sh "kubectl config set-context \"${RancherNamespace}\" --user=\"${RancherUser}\" --cluster=\"${RancherCluster}\""
    sh "kubectl config use-context \"${RancherNamespace}\""
    sh "kubectl patch serviceaccount default -p '{\"imagePullSecrets\": [{\"name\": \"${RancherSecret}\"}]}' --namespace=${RancherNamespace} || true"
    sh "mkdir tmp"
    dir('tmp') {
        sh "kompose convert -f ../${RancherComposeFile}"
	sh "kubectl apply -f ./ --namespace=${RancherNamespace}"
    }
}    