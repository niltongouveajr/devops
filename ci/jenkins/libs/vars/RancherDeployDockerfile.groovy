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
 * env.RancherDockerRegistryImage
 * env.RancherDockerRegistryImageVersion
 * env.RancherDockerInternalPort
 */

def call(){
     try {
        RancherUser
        RancherToken
        RancherServer
        RancherCluster
        RancherNamespace
        RancherSecret
        RancherDeployment
        RancherDockerRegistryImage
        RancherDockerRegistryImageVersion
        RancherDockerInternalPort
    } catch (e) {
        throw new RuntimeException("Please ensure the " +
            "'env.RancherUser' and " +
            "'env.RancherToken' and " +
            "'env.RancherServer' and " +
            "'env.RancherCluster' and " +
            "'env.RancherNamespace' and " +
            "'env.RancherSecret' and " +
            "'env.RancherDeployment' and " +
            "'env.RancherDockerRegistryImage' and " +
            "'env.RancherDockerRegistryImageVersion' and " +
            "'env.RancherDockerInternalPort'  " +
            "variables must be set on your main Jenkinsfile")
    }
    sh "docker build -t ${RancherDockerRegistryImage}:${RancherDockerRegistryImageVersion} ."
    sh "docker push ${RancherDockerRegistryImage}:${RancherDockerRegistryImageVersion}"
    sh "kubectl config set-credentials \"${RancherUser}\" --token \"${RancherToken}\""
    sh "kubectl config set-cluster \"${RancherCluster}\" --insecure-skip-tls-verify=\"true\" --server=\"${RancherServer}\""
    sh "kubectl config set-context \"${RancherNamespace}\" --user=\"${RancherUser}\" --cluster=\"${RancherCluster}\""
    sh "kubectl config use-context \"${RancherNamespace}\""
    sh "kubectl patch serviceaccount default -p '{\"imagePullSecrets\": [{\"name\": \"${RancherSecret}\"}]}' --namespace=${RancherNamespace} || true"
    sh "kubectl delete deployments ${RancherDeployment} --namespace=${RancherNamespace} || true"
    sh "kubectl delete services ${RancherDeployment} --namespace=${RancherNamespace} || true"
    sh "kubectl run ${RancherDeployment} --image=${RancherDockerRegistryImage}:${RancherDockerRegistryImageVersion} --port=${RancherDockerInternalPort} --namespace=${RancherNamespace} --image-pull-policy Always"
    sh "kubectl expose deployment/${RancherDeployment} --type=\"NodePort\" --port ${RancherDockerInternalPort} --namespace=${RancherNamespace}"
    script {
        RancherService = sh(returnStdout: true, script: "kubectl describe service ${RancherDeployment} --namespace=${RancherNamespace} | grep ^Annotations | awk -F '\"' '{print \$4\$7}' | sed 's|,\$||g' | sed 's|^|http://|g'").trim()
        sh "echo ${RancherService}"
        summary = manager.createSummary("star-gold.gif")
        summary.appendText("<a href=\"${RancherService}\">${RancherDeployment} on Rancher</a>", false)
    }
}
