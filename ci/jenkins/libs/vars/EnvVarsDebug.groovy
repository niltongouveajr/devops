#!/usr/bin/env groovy

/*
 * For more information about this library, please see: https://gitlab.domain.local/shared/ci-utils/jenkins
 */

def call(){
    echo "------------------------------------"
    echo " BEGIN: Environment Variables Debug "
    echo "------------------------------------"
    echo sh(script: 'env | sort', returnStdout: true)
    echo "------------------------------------"
    echo " END:   Environment Variables Debug "
    echo "------------------------------------"
}
