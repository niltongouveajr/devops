#!/usr/bin/env groovy

/**
 * For more information about this library, please see: https://gitlab.domain.local/shared/ci-utils/jenkins
 * Variables that need to be set for this lib to work correctly:
 * env.RancherCredential
 * env.RancherDockerRegistryImage
 * env.RancherDockerRegistryImageVersion
 * env.RancherProject
 * env.RancherNamespace
 * env.RancherDeployment
 */

def call(){
     try {
        RancherCredential
        RancherDockerRegistryImage
        RancherDockerRegistryImageVersion
        RancherProject
        RancherNamespace
        RancherDeployment

    } catch (e) {
        throw new RuntimeException("Please ensure the " +
            "'env.RancherCredential' and " +
            "'env.RancherDockerRegistryImage' and " +
            "'env.RancherDockerRegistryImageVersion' and " +
            "'env.RancherProject' and " +
            "'env.RancherNamespace' and " +
            "'env.RancherDeployment' and " +
            "variables must be set on your main Jenkinsfile")
    }
    rancherRedeploy alwaysPull: true, credential: "${RancherCredential}", images: "${RancherDockerRegistryImage}:${RancherDockerRegistryImageVersion}", workload: "/project/c-5fgmv:${RancherProject}/workloads/deployment:${RancherNamespace}:${RancherDeployment}" 
}
