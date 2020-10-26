#!/usr/bin/env groovy

/*
 * For more information about this library, please see: README.md
 */

def call(){
    echo "------------------------------------"
    echo " BEGIN: Environment Variables Debug "
    echo "------------------------------------"
    echo bat(script: 'env | sort', returnStdout: true)
    echo "------------------------------------"
    echo " END:   Environment Variables Debug "
    echo "------------------------------------"
}
