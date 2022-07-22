#!/usr/bin/env groovy

/**
 * For more information about this library, please see: https://gitlab.domain.local/shared/ci-utils/jenkins
 * Variables that need to be set for this lib to work correctly:
 *  env.DotNETVersion
 */

def call() {
    try {
        env.DotNETVersion
    } catch (e) {
        throw new RuntimeException("Please ensure the " +
            "'env.DotNETVersion' " +
            "variables must be set on your main Jenkinsfile")
    }

    script {
        sh "dotnet-install.sh --channel ${DotNETVersion} -InstallDir /opt/tools/dotnet-versions/${DotNETVersion}"
        sh "ln -sf /opt/tools/dotnet-versions/${DotNETVersion} /opt/tools/dotnet"
        sh "sudo ln -sf /opt/tools/dotnet-versions/${DotNETVersion}/dotnet /usr/local/bin/dotnet"
        sh "dotnet --version || true"
    }
}
