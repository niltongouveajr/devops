#!/usr/bin/env groovy

/**
 * For more information about this library, please see: https://gitlab.domain.local/shared/ci-utils/jenkins
 * Variables that need to be set for this lib to work correctly:
 * env.BuildPath
 * env.MSBuildSolution
 * env.SonarProjectKey
 * env.SonarExclusions
 * env.SonarRunnerVersion
 * env.SonarVersion
 */

def call(){
    script {
        try {
            BuildPath
            MSBuildSolution
            SonarProjectKey
            SonarExclusions
            SonarRunnerVersion
            SonarVersion
        } catch (e) {
            throw new RuntimeException("Please ensure the " +
                "'env.BuildPath' and " +
                "'env.MSBuildSolution' and " +
                "'env.SonarProjectKey' and " +
                "'env.SonarExclusions' and " +
                "'env.SonarRunnerVersion' and " +
                "'env.SonarVersion' " +
                "variable must be set on your main Jenkinsfile")
        }
        //def sqScannerMsBuildHome = tool 'MSBuild SonarQube Scanner 4.0'
        //def sqScannerMsBuildHome = tool 'MSBuild SonarQube Scanner 4.6'
        def sqScannerMsBuildHome = tool 'MSBuild SonarQube Scanner 5.3'
        withSonarQubeEnv("sonar-${env.SonarVersion}") {
            //bat "${sqScannerMsBuildHome}\\SonarQube.Scanner.MSBuild.exe begin /k:${env.SonarProjectKey} /d:sonar.exclusions=${env.SonarExclusions}"
            bat "${sqScannerMsBuildHome}\\SonarScanner.MSBuild.exe begin /k:${env.SonarProjectKey} /d:sonar.exclusions=${env.SonarExclusions}"
            //bat "C:\\dotnet\\${env.DotNETVersion}\\dotnet.exe new globaljson --sdk-version ${env.DotNETVersion}"
            bat "\"${tool "msbuild-${env.MSBuildVersion}"}\" ${env.MSBuildSolution} /t:Rebuild"
            //bat "${sqScannerMsBuildHome}\\SonarQube.Scanner.MSBuild.exe end"
            bat "${sqScannerMsBuildHome}\\SonarScanner.MSBuild.exe end"
        }
    }
}
