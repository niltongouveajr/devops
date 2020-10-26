#!/usr/bin/env groovy

/**
 * For more information about this library, please see: README.md
 * Variables that must be filled to this script work:
 * env.BuildPath
 * env.MSBuildSolution
 * env.SonarProjectKey
 * env.SonarExclusions
 * env.SonarRunnerVersion
 * env.SonarVersion
 * env.SonarTestsDLLFile
 * env.SonarTestsReportPath
 */

/**
 * Reference: https://docs.sonarqube.org/pages/viewpage.action?pageId=6389772
 */

def call(){
    env.VSTestPath = '"C:\\Program Files (x86)\\Microsoft Visual Studio\\2017\\BuildTools\\Common7\\IDE\\Extensions\\TestPlatform"'
    script {
        try {
            BuildPath
            MSBuildSolution
            SonarProjectKey
            SonarExclusions
            SonarRunnerVersion
            SonarVersion
            SonarTestsDLLFile
            SonarTestsReportPath
        } catch (e) {
            throw new RuntimeException("Please ensure the " +
                "'env.BuildPath' and " +
                "'env.MSBuildSolution' and " +
                "'env.SonarProjectKey' and " +
                "'env.SonarExclusions' and " +
                "'env.SonarRunnerVersion' and " +
                "'env.SonarVersion' and " +
                "'env.SonarTestsDLLFile' and " +
                "'env.SonarTestsReportPath' " +
                "variable must be set on your main Jenkinsfile")
        }
        def sqScannerMsBuildHome = tool 'MSBuild SonarQube Scanner 4.0'
        withSonarQubeEnv("sonar-${SonarVersion}") {
            dir(BuildPath) {
                bat "${env.VSTestPath}\\vstest.console.exe ${env.SonarTestsDLLFile} /InIsolation /Logger:trx && set ERRORLEVEL=0"
                bat "${sqScannerMsBuildHome}\\SonarQube.Scanner.MSBuild.exe begin /k:${env.SonarProjectKey} /d:sonar.verbose=true /d:sonar.cs.vstest.reportsPaths=${env.SonarTestsReportPath} /d:sonar.exclusions=${env.SonarExclusions}"
                bat "\"${tool "msbuild-${MSBuildVersion}"}\" ${MSBuildSolution} /t:Rebuild"
                bat "${sqScannerMsBuildHome}\\SonarQube.Scanner.MSBuild.exe end"
            }
        }
    }
}
