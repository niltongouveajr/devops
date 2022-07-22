#!/usr/bin/env groovy

/**
 * For more information about this library, please see: https://gitlab.domain.local/shared/ci-utils/jenkins
**/

def call() {
    script {
        sh "mkdir -p reports"
        dependencycheck additionalArguments: '--project ${JOB_NAME} --scan ./ --data ${HOME}/.m2/dependency-check --out reports --format XML', odcInstallation: 'dependency-check-6.3.2'
        dependencyCheckPublisher pattern: 'reports/dependency-check-report.xml'
    }
}
