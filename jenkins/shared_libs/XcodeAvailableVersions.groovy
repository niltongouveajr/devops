#!/usr/bin/env groovy

/**
 * For more information about this library, please see: README.md
 * Variables that must be filled to this script work:
 * env.XcodeVersion
 */
 
def call() {
    sh "system_profiler SPDeveloperToolsDataType"
}
