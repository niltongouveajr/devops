#!/usr/bin/env groovy
import groovy.json.JsonSlurper

/**
 * For more information about this library, please see: README.md
 * Variables that must be filled to this script work:
 * env.SonarURL
 * env.SonarLogin
 * env.SonarProjectKey
 * env.SonarMinPercentage
 */

def encodeURL(parameterToEncode) {
    return URLEncoder.encode(parameterToEncode, "UTF-8")
}
def getAuthorization() {
    def sonarAuth = "${SonarLogin}"
    def base64 = Base64.getUrlEncoder().encodeToString("${sonarAuth}:".getBytes(java.nio.charset.StandardCharsets.UTF_8))
    return base64;
}
def call() {
    script {
        try {
            SonarURL
            SonarLogin
            SonarProjectKey
            SonarMinPercentage
        } catch (e) {
            throw new RuntimeException("Please ensure the " +
                "'env.SonarURL' and " +
                "'env.SonarLogin' and " +
                "'env.SonarProjectKey' and " +
                "'env.SonarMinPercentage' " +
                "variable must be set on your main Jenkinsfile")
        }
        echo "[SonarQubeCoverage] initializing min coverage detection"
        def endpoint = "${SonarURL}/api/measures/search?format=json&metricKeys=coverage&projectKeys=${encodeURL(SonarProjectKey)}&format=json"
        echo "[SonarQubeCoverage] obtaining results from sonar '${endpoint}' "
        def response = httpRequest url: endpoint,
                       httpMode: 'GET',
                       customHeaders: [[name: 'Authorization', value: "Basic ${getAuthorization()}"]],
                       consoleLogResponseBody: false,
                       contentType: 'APPLICATION_JSON'
        if (response.status == 200) {
            def json = new JsonSlurper().parseText(response.content)
            json.measures?.each { measure ->
                if (measure.metric == "coverage") {
                    def coverage = measure.value
                    if (Float.valueOf(coverage) < Float.valueOf(SonarMinPercentage)) {
                        throw new RuntimeException("[SonarQubeCoverage] Coverage is lower than required (required: '${SonarMinPercentage}', found: '${coverage}')")
                    }
                }
            }
        } else {
              throw new RuntimeException("Error requesting URL '${url}' responseCode: '${response.status}'");
        }
        echo "[SonarQubeCoverage] end of script"
    }
}
