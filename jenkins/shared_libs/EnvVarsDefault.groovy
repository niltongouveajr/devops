#!/usr/bin/env groovy

/**
 * For more information about this library, please see: README.md
 */

def call() {
    env.ANDROID_HOME = "/srv/hudson/android/android-sdk-linux-complete"
    env.AWS_CLI_HOME = "/var/lib/hudson/.local/bin"
    env.CHROME_BIN = "/usr/bin/google-chrome"
    env.EMAIL_IMAGES_LOCATION = "/srv/hudson/others/images/"
    env.GRADLE_HOME= "/opt/tools/others/gradle"
    env.JAVA_HOME = "/opt/tools/java${JdkVersion}"
    env.N_PREFIX = "$HOME/n"
    env.RANCHER_BIN = "/srv/hudson/rancher"
    env.PATH = "$AWS_CLI_HOME:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:$ANDROID_HOME/tools:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$CHROME_BIN:$GRADLE_HOME/bin:$JAVA_HOME/bin:$N_PREFIX/bin:$RANCHER_BIN"
    script {
        if ( "${NodeVersion}" != "lts" ) {
            sh "NODE_MIRROR=http://nodejs.org/dist/ n ${NodeVersion} -rg"
        }
    }
    JavaSwitchVersion()
}
