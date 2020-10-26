#!/usr/bin/env groovy

/**
 * For more information about this library, please see: README.md
 * Variables that must be filled to this script work:
 * env.GitRestrictedSource
 */

def call() {
    try {
        GitRestrictedSource
    } catch (e) {
        throw new RuntimeException("Please ensure the " +
            "'env.GitRestrictedSource' " +
            "variable must be set on your main Jenkinsfile")
    }
    script {
        env.GitSource = "${env.GIT_BRANCH}"
        if (env.GitSource.equals(env.GitRestrictedSource) == true) {
            echo "Git source '${env.GitSource}' is valid."
        } else { 
            error "Git source '${env.GitSource}' is not valid. Allowed source: '${env.GitRestrictedSource}'"
        }
    }
}
