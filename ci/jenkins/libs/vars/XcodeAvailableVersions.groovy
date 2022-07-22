#!/usr/bin/env groovy

/**
 * For more information about this library, please see: https://gitlab.domain.local/shared/ci-utils/jenkins
 * Variables that need to be set for this lib to work correctly:
 * env.XcodeVersion
 */
 
def call() {
    sh "system_profiler SPDeveloperToolsDataType"
}
