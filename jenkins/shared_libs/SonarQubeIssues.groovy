#!/usr/bin/env groovy
import groovy.json.JsonSlurper

/**
 * For more information about this library, please see: README.md
 * Variables that must be filled to this script work:
 * env.SonarURL
 * env.SonarLogin
 * env.SonarProjectKey
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
        } catch (e) {
            throw new RuntimeException("Please ensure the " +
                "'env.SonarLogin' and " +
                "'env.SonarProjectKey' " +
                "variable must be set on your main Jenkinsfile")
        }
        def MaxSeveritiesCounter = [
            BLOCKER: 0,
            CRITICAL: 0,
            MAJOR: -1,
            MINOR: -1,
            INFO: -1
        ]
        try {
            def jsonSevCounter = new JsonSlurper().parseText(SonarMaxSeveritiesCounter)
            jsonSevCounter.each { key, value ->
                MaxSeveritiesCounter[key] = value
            }
        } catch (e) {
            echo "No maximum severities counter found. Using default."
            throw e
        }
        echo "[SonarQubeIssues] initializing issues detection MaxSeveritiesCounter: ${MaxSeveritiesCounter}"
        def endpoint = "${SonarURL}/api/issues/search?componentKeys=${encodeURL(SonarProjectKey)}&s=FILE_LINE&resolved=false&ps=100&facets=severities%2Ctypes&additionalFields=_all"
        echo "[SonarQubeIssues] Obtaining results from sonar '${endpoint}' "
        def response = httpRequest url: endpoint,
                       httpMode: 'GET',
                       customHeaders: [[name: 'Authorization', value: "Basic ${getAuthorization()}"]],
                       consoleLogResponseBody: false,
                       contentType: 'APPLICATION_JSON'
        if (response.status == 200) {
            def json = new JsonSlurper().parseText(response.content)
            json.facets.each { facet -> 
                if (facet.property == "severities") {
                    facet.values.each { value ->
                        def severity = value.val
                        def count = value.count
                        def maxTolerance = MaxSeveritiesCounter[severity]
                        if (maxTolerance > -1 && 
                            count > maxTolerance) {
                            throw new RuntimeException("[SonarQubeIssues] Sonar issues have been found. Please fix this issues before continue: [${severity}] Found: ${count} / Max: ${maxTolerance}")
                        }
                    }
                }
            }
        } else {
            throw new RuntimeException("Error requesting URL '${url}' responseCode: '${response.status}'");
        }
        echo "[SonarQubeIssues] end of script"
    }
}
call()
