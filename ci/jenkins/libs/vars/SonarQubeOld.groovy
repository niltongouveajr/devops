#!/usr/bin/env groovy

/**
 * For more information about this library, please see: https://gitlab.domain.local/shared/ci-utils/jenkins
 * Variables that need to be set for this lib to work correctly:
 * env.SonarVersion
 * env.SonarRunnerVersion
 * env.SonarScannerHome
 */

def call(){
    script {
        env.SONAR_HOST_URL = "http://sonar.domain.local:9895"
        env.SonarVersion = "8.9.5-old";
        env.SonarRunnerVersion = "4.6.2";
        def SonarScannerHome = tool "sonar_runner_${SonarRunnerVersion}";
        withSonarQubeEnv("sonar-${SonarVersion}") {
            sh "${SonarScannerHome}/bin/sonar-scanner"
        }
    }
}
