#!/usr/bin/env groovy

/**
 * For more information about this library, please see: README.md
 */

def call(){
    script {
        sh "sleep 15"
        timeout(time: 5, unit: 'MINUTES') { 
            def qualityGate = waitForQualityGate() 
            if (qualityGate.status != 'OK') {
                echo "The code does not conform with the Sonar rules: ${qualityGate.status}"
                error "The code does not conform with the Sonar rules: ${qualityGate.status}"
            }
        }
    }
}
