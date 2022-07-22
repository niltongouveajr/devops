#!/usr/bin/env groovy

/**
 * For more information about this library, please see: https://gitlab.domain.local/shared/ci-utils/jenkins
 */

def call(){
    if (isUnix()) {
        def uname = sh script: 'uname', returnStdout: true
        if (uname.startsWith("Darwin")) {
            env.OperatingSystem = "MacOS"
            echo "Operating System: ${env.OperatingSystem}" 
        }
        // Optionally add 'else if' for other Unix OS  
        else {
            env.OperatingSystem = "Linux" 
            echo "Operating System: ${env.OperatingSystem}" 
        }
    }
    else {
        env.OperatingSystem = "Windows" 
        echo "Operating System: ${env.OperatingSystem}"
    }
}
