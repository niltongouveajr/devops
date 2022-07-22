#!/usr/bin/env groovy

/**
 * For more information about this library, please see: https://gitlab.domain.local/shared/ci-utils/jenkins
 */

def call(){
    script {
        env.SONAR_HOST_URL = "https://sonarqube.domain.local"
        env.SonarVersion = "8.9.8";
        env.SonarRunnerVersion = "4.7.0";
        def SonarScannerHome = tool "sonar_runner_${SonarRunnerVersion}";
        withSonarQubeEnv("sonar-${SonarVersion}") {
            sh "${SonarScannerHome}/bin/sonar-scanner"
        }
    }
}
