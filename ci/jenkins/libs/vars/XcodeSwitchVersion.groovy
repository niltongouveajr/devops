#!/usr/bin/env groovy

/**
 * For more information about this library, please see: https://gitlab.domain.local/shared/ci-utils/jenkins
 * Variables that need to be set for this lib to work correctly:
 * env.XcodeVersion
 */

def call() {
    try {
        XcodeVersion
    } catch (e) {
        throw new RuntimeException("Please ensure the " +
            "'env.XcodeVersion' " +
            "variables must be set on your main Jenkinsfile")
    }
    env.XcodePath = "/Applications/Xcode-${env.XcodeVersion}/Xcode.app"
    env.XcodeBuildCommand = "/usr/bin/xcode-select"
    sh "sudo ${env.XcodeBuildCommand} -switch ${env.XcodePath}"
    sh "xcodebuild -version"
    sh "swift --version"
    sh "sw_vers"
}
