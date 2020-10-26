#!/usr/bin/env groovy

/**
 * For more information about this library, please see: README.md
 * Variables that must be filled to this script work:
 * env.BuildJobName
 * env.BuildJobBranch
 */

def call() {
    try {
        BuildJobName
        BuildJobBranch
    } catch (e) {
        throw new RuntimeException("Please ensure the " +
            "'env.BuildJobName' and " +
            "'env.BuildJobBranch' and " +
            "variable must be set on your main Jenkinsfile")
    }
    build job: "${env.BuildJobName}",
       parameters: [
       		string(name: 'gitlabBranch', value: "${env.BuildJobBranch}")
    ] 

}