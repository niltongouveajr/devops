#!/usr/bin/env groovy

/**
 * For more information about this library, please see: https://gitlab.domain.local/shared/ci-utils/jenkins
 * Variables that need to be set for this lib to work correctly:
 * None
 */

def call(){
    script {

        /////////////
        // Insider // 
        ////////////

        sh "mkdir -p reports/insider && cd reports/insider && insider -target \"${WORKSPACE}\" -exclude \"git|jpg|pdf|mp4|png|report.html|report.json|svg|webm\" -tech android java ios javascript csharp -security 0 -v"
        publishHTML target: [
            allowMissing: true,
            alwaysLinkToLastBuild: false,
            keepAll: true,
            reportDir: "reports/insider",
            reportFiles: "report.html",
            reportName: "Insider Application Security"
        ]

        //////////////////// 
        // Shiftleft Scan //
        ///////////////////

        /*
        sh "scan --build --out_dir security-reports --local-only --no-error"
        //sh "docker run --rm --tmpfs /tmp -e \"SCAN_DEBUG_MODE=debug\" -e \"WORKSPACE=${WORKSPACE}\" -v ${WORKSPACE}:/app shiftleft/scan-oss:latest scan --build --src /app --type ansible,aws,bash,credscan,depscan,go,groovy,java,jsp,json,kotlin,scala,kubernetes,nodejs,php,plsql,python,ruby,terraform,yaml --out_dir /app/security-reports --mode ci --no-error"
        //sh "export SCAN_DEBUG_MODE=debug && scan --build --src \"${WORKSPACE}\" --type \"ansible,aws,bash,credscan,depscan,go,groovy,java,jsp,json,kotlin,scala,kubernetes,nodejs,plsql,python,ruby,terraform,yaml\" --out_dir \"${WORKSPACE}/security-reports\" --mode \"ci\" --no-error"
        ZipFile("security-reports", "security-reports.zip", "temp")
        archiveArtifacts artifacts: 'security-reports.zip', allowEmptyArchive: true
        */

    }
}
