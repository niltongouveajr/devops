#!/usr/bin/env groovy

/**
 * For more information about this library, please see: https://gitlab.domain.local/shared/ci-utils/jenkins
 */

import java.nio.file.Files
import java.io.File

def downloadFile(url, file) {
    if (isUnix()) {
        sh "wget -q ${url} -O ${file} --no-check-certificate"
    } else {
        EnvVarsDefaultWin()
        bat "wget -q ${url} -O ${file} --no-check-certificate"
    }
}

def call(url, destinationFile) {
    script {
        downloadFile(url, source)
    }
}
