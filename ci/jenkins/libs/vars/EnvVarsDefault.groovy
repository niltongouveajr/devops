#!/usr/bin/env groovy

/**
 * For more information about this library, please see: https://gitlab.domain.local/shared/ci-utils/jenkins
 */

def call() {
    if (isUnix()) {
        def uname = sh script: 'uname', returnStdout: true
        if (uname.startsWith("Darwin")) {
            // MacOS
            env.ANDROID_HOME = "/private/var/lib/hudson/Library/Android/sdk"
            env.EMAIL_IMAGES_LOCATION = "/srv/hudson/others/images/"
            env.FLUTTER_BIN = "/opt/tools/flutter/bin"
            env.GRADLE_HOME = "/opt/tools/gradle/bin"
            env.JAVA_HOME = "/opt/tools/java${JdkVersion}"
            env.LC_ALL = "en_US.UTF-8"
            env.N_PREFIX = "$HOME/n"
            env.PATH = "/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:$FLUTTER_BIN:$GRADLE_HOME/bin:$JAVA_HOME/bin:/Library/Apple/usr/bin:$N_PREFIX/bin"
            script {
                if ( "${NodeVersion}" != "default" ) {
                    //sh "NODE_MIRROR=http://nodejs.org/dist/ n ${NodeVersion} -rg >/dev/null"
                    sh "n ${NodeVersion} -rg >/dev/null"
                }
            }
        }
        else {
            // Linux
            env.ANDROID_HOME = "/srv/hudson/android/android-sdk-linux-complete"
            env.AWS_CLI_HOME = "/var/lib/hudson/.local/bin"
            env.CHROME_BIN = "/usr/bin/google-chrome"
            env.DOTNET_HOME = "$HOME/.dotnet/tools"
            env.EMAIL_IMAGES_LOCATION = "/srv/hudson/others/images/"
            env.FLUTTER_BIN = "/opt/tools/flutter/bin"
            env.GRADLE_HOME= "/opt/tools/others/gradle"
            env.JAVA_HOME = "/opt/tools/java${JdkVersion}"
            env.KUBERNETES_BIN = "/srv/config/tools/kubernetes"
            env.KUBERNETES_MASTER = "https://rancher.domain.local/k8s/clusters/c-5fgmv"
            env.N_PREFIX = "$HOME/n"
            env.SECURITY_BIN = "/srv/config/tools/security"
            env.TERRAFORM_BIN = "/srv/config/tools/terraform"
            env.PATH = "$AWS_CLI_HOME:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:$ANDROID_HOME/tools:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$CHROME_BIN:$DOTNET_HOME:$FLUTTER_BIN:$GRADLE_HOME/bin:$JAVA_HOME/bin:$KUBERNETES_BIN:$N_PREFIX/bin:$SECURITY_BIN:$TERRAFORM_BIN"
            script {
                if ( "${NodeVersion}" != "default" ) {
                    //sh "NODE_MIRROR=http://nodejs.org/dist/ n ${NodeVersion} -rg >/dev/null"
                    sh "n ${NodeVersion} -rg >/dev/null"
                }
            }
            JavaSwitchVersion()
        }
    }
    else {
        // Windows
        EnvVarsDefaultWin()
    }
}
