#!/usr/bin/env groovy

/**
 * For more information about this library, please see: README.md
 * Variables that must be filled to this script work:
 * env.SonarRunnerVersion
 * env.SonarVersion
 */

def call(){
    script {
        try {
            SonarRunnerVersion
            SonarVersion
        } catch (e) {
            throw new RuntimeException("Please ensure the " +
                "'env.SonarRunnerVersion' and " +
                "'env.SonarVersion' " +
                "variable must be set on your main Jenkinsfile")
        }
        def scannerHome = tool "sonar_runner_${SonarRunnerVersion}";
        withSonarQubeEnv("sonar-${SonarVersion}") {
            sh "${scannerHome}/bin/sonar-scanner"
        }
    }
}
