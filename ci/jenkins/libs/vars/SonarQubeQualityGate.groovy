#!/usr/bin/env groovy

/**
 * For more information about this library, please see: https://gitlab.domain.local/shared/ci-utils/jenkins
 */

def call(){
    script {
        //sh "sleep 15"
        def qualityGate = waitForQualityGate() 
        if (qualityGate.status != 'OK') {
            echo "The code does not conform with the Sonar rules: ${qualityGate.status}"
            error "The code does not conform with the Sonar rules: ${qualityGate.status}"
        }
    }
}
