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
        // Changed default AzureFeed
        // from: https://dotnetcli.azureedge.net/dotnet
        // to  : https://dotnetcli.blob.core.windows.net/dotnet
        //powershell "c:\\dotnet\\dotnet-install.ps1 -Channel ${DotNETVersion} -InstallDir c:\\dotnet\\${DotNETVersion}"
        powershell "c:\\dotnet\\dotnet-install.ps1 -Channel ${DotNETVersion} -InstallDir c:\\dotnet\\${DotNETVersion} -AzureFeed https://dotnetcli.blob.core.windows.net/dotnet"
        bat "c:\\dotnet\\${DotNETVersion}\\dotnet --version || true"
    }
}
