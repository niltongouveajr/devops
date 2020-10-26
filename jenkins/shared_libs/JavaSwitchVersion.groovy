#!/usr/bin/env groovy

/**
 * For more information about this library, please see: README.md
 * Variables that must be filled to this script work:
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
        if (env.JdkVersion == '6') {
            sh "source $HOME/.sdkman/bin/sdkman-init.sh && yes n | sdk install java 6.0.119-zulu || true && sdk use java 6.0.119-zulu"
        }
        if (env.JdkVersion == '7') {
            sh "source $HOME/.sdkman/bin/sdkman-init.sh && yes n | sdk install java 7.0.262-zulu || true && sdk use java 7.0.262-zulu"
        }
        if (env.JdkVersion == '8') {
            sh "source $HOME/.sdkman/bin/sdkman-init.sh && yes n | sdk install java 8.0.252-open || true && sdk use java 8.0.252-open"
        }
        if (env.JdkVersion == '9') {
            sh "source $HOME/.sdkman/bin/sdkman-init.sh && yes n | sdk install java 9.0.4-open || true && sdk use java 9.0.4-open"
        }
        if (env.JdkVersion == '10') {
            sh "source $HOME/.sdkman/bin/sdkman-init.sh && yes n | sdk install java 10.0.2-open || true && sdk use java 10.0.2-open"
        }
        if (env.JdkVersion == '11') {
            sh "source $HOME/.sdkman/bin/sdkman-init.sh && yes n | sdk install java 11.0.7-open || true && sdk use java 11.0.7-open && java -version"
        }
        if (env.JdkVersion == '12') {
            sh "source $HOME/.sdkman/bin/sdkman-init.sh && yes n | sdk install java 12.0.2-open || true && sdk use java 12.0.2-open"
        }
        if (env.JdkVersion == '13') {
            sh "source $HOME/.sdkman/bin/sdkman-init.sh && yes n | sdk install java 13.0.2-open || true && sdk use java 13.0.2-open"
        }
        if (env.JdkVersion == '14') {
            sh "source $HOME/.sdkman/bin/sdkman-init.sh && yes n | sdk install java 14.0.1-open || true && sdk use java 14.0.1-open"
        }
    }
}
