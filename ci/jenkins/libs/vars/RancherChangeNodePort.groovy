#!/usr/bin/env groovy

/**
 * For more information about this library, please see: https://gitlab.domain.local/shared/ci-utils/jenkins
 * Variables that need to be set for this lib to work correctly:
 *  env.RancherDeployment
 *  env.RancherNamespace
 *  env.RancherNodePort
 */

def call(RancherDeployment, RancherNamespace, RancherNodePort) {
    try {
        env.RancherDeployment
        env.RancherNamespace
        env.RancherNodePort
    } catch (e) {
        throw new RuntimeException("Please ensure the " +
            "'env.RancherDeployment' and " +
            "'env.RancherNamespace' and " +
            "'env.RancherNodePort' " +
            "variables must be set on your main Jenkinsfile")
    }

    script {
        sh "kubectl patch service ${RancherDeployment} --namespace=${RancherNamespace} --type='json' --patch='[{\"op\": \"replace\", \"path\": \"/spec/ports/0/nodePort\", \"value\":${RancherNodePort}}]' || true"
    }
}
