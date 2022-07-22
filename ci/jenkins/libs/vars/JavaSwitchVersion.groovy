#!/usr/bin/env groovy

/**
 * For more information about this library, please see: https://gitlab.domain.local/shared/ci-utils/jenkins
 * Variables that need to be set for this lib to work correctly:
 * env.JdkVersion
 */

def call() {
    try {
        JdkVersion
    } catch (e) {
        throw new RuntimeException("Please ensure the " +
            "'env.JdkVersion' and " +
            "variable must be set on your main Jenkinsfile")
    }
    script {
        // Reference: https://dzone.com/articles/how-to-install-multiple-versions-of-java-on-the-sa
        //sh "curl -s https://get.sdkman.io | bash"
        //sh "source $HOME/.sdkman/bin/sdkman-init.sh >/dev/null 2>/dev/null"
        if (env.JdkVersion == '7') {
            sh "source $HOME/.sdkman/bin/sdkman-init.sh && yes n | sdk install java 7.0.262-zulu || true && sdk use java 7.0.262-zulu"
        }
        //if (env.JdkVersion == '8') {
        //    //sh "source $HOME/.sdkman/bin/sdkman-init.sh && yes n | sdk install java 8.0.252-open || true && sdk use java 8.0.252-open"
        //}
        if (env.JdkVersion == '8-') {
            sh "source $HOME/.sdkman/bin/sdkman-init.sh && yes n | sdk install java 8.0.265-open || true && sdk use java 8.0.265-open"
        }
        if (env.JdkVersion == '11') {
            sh "source $HOME/.sdkman/bin/sdkman-init.sh && yes n | sdk install java 11.0.12-open || true && sdk use java 11.0.12-open"
        }
        if (env.JdkVersion == '14') {
            sh "source $HOME/.sdkman/bin/sdkman-init.sh && yes n | sdk install java 14.0.2-open || true && sdk use java 14.0.2-open"
        }
        if (env.JdkVersion == '17') {
            sh "source $HOME/.sdkman/bin/sdkman-init.sh && yes n | sdk install java 17.0.3-zulu || true && sdk use java 17.0.3-zulu"
        }
    }
}
