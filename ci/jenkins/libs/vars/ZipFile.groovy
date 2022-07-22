#!/usr/bin/env groovy

/*
 * For more information about this library, please see: https://gitlab.domain.local/shared/ci-utils/jenkins
 */

import java.nio.file.Files
import java.util.zip.ZipEntry
import java.util.zip.ZipOutputStream
import hudson.FilePath

def call(sourceFile, destinationFile, ignoreFiles) {
    script {
        dir(WORKSPACE) {
            if (isUnix()) {
                sh "zip -r ${destinationFile} ${sourceFile} -x \"${ignoreFiles}\" -x \"*@tmp*\""
            } else {
                EnvVarsDefaultWin()
                //bat "7z.exe d ${destinationFile} ${sourceFile} -r -xr!${ignoreFiles} -xr!@tmp"
                bat "7z.exe a ${destinationFile} ${sourceFile} -r -xr!${ignoreFiles} -xr!@tmp"
            }
        }
    }
}
