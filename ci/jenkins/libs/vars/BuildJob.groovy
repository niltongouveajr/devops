#!/usr/bin/env groovy

/**
 * For more information about this library, please see: https://gitlab.domain.local/shared/ci-utils/jenkins
 * Variables that need to be set for this lib to work correctly:
 * env.BuildJobName
 * env.BuildJobBranch
 */

def call(BuildJobName, BuildJobBranch) {
    build job: "${env.BuildJobName}",
        parameters: [
            string(name: 'gitlabBranch', value: "${env.BuildJobBranch}")
        ] 
}
