#!/usr/bin/env groovy

/**
 * For more information about this library, please see: https://gitlab.domain.local/shared/ci-utils/jenkins
 * Variables that need to be set for this lib to work correctly:
 * env.SonarProjectKey
 */

def call(){
    try {
        SonarProjectKey
    } catch (e) {
        throw new RuntimeException("Please ensure the " +
            "'env.SonarProjectKey' " +
            "variables must be set on your main Jenkinsfile")
    }
    script {
        withCredentials([usernamePassword(credentialsId: '00000000-0000-0000-0000-000000000000', usernameVariable: 'SONAR_URL', passwordVariable: 'SONAR_TOKEN'), string(credentialsId: 'devsecops-elasticsearch-url', variable: 'ELASTICSEARCH_URL')]) {            
            sh '''

set +x

# Variables

SONARQUBE_API_URL="\${SONAR_URL}/api"
SONARQUBE_API_TOKEN="\${SONAR_TOKEN}"
SONARQUBE_PROJECT_KEY="\${SonarProjectKey}"
SONARQUBE_METRICS_OUTPUT="./sonarqube_metrics.json"
SONARQUBE_METRICS_KEYS="alert_status,bugs,code_smells,cognitive_complexity,comment_lines,comment_lines_density,complexity,coverage,critical_violations,development_cost,duplicated_blocks,duplicated_lines,effort_to_reach_maintainability_rating_a,false_positive_issues,last_commit_date,files,lines_to_cover,ncloc,open_issues,quality_gate_details,quality_profiles,reliability_rating,reliability_remediation_effort,reopened_issues,rules_compliance_index,rules_compliance_rating,security_hotspots,security_hotspots_reviewed,security_rating,security_remediation_effort,security_review_rating,security_hotspots_reviewed_status,security_hotspots_to_review_status,skipped_tests,sqale_debt_ratio,sqale_index,sqale_rating,test_execution_time,test_errors,test_failures,test_success_density,tests,violations,vulnerabilities,wont_fix_issues"
SONARQUBE_LAST_ANALYSIS="$(curl -k -s -u "${SONARQUBE_API_TOKEN}" "${SONARQUBE_API_URL}/project_analyses/search?project=${SONARQUBE_PROJECT_KEY}" | python -m json.tool | grep date | head -n 1 | awk -F "\\"" '{print \$4}' | sed "s|-0300|\\.000Z|g")"

# Get SonarQube metrics from specific project

curl -k -s -u "${SONARQUBE_API_TOKEN}" "${SONARQUBE_API_URL}/measures/component?component=${SONARQUBE_PROJECT_KEY}&metricKeys=${SONARQUBE_METRICS_KEYS}" | jq 'del(.component.qualifier)' | grep -v "bestValue" | sed '/^ *\\}/{H;x;s/\\([^}]\\),\\n/\\1\\n/;b};x;/^ *}/d' | sed "s|\\"metric\\": ||g" | sed "s|\\"value\\"||g" | awk -v RS= '{\$1=\$1}1' | sed "s|, :|:|g" | sed "s| }\$||g" | python -m json.tool | sed "s| - |,\\n    \\"project\\": \\"|g" | sed "s|\\"name\\":|\\"customer\\":|g" | sed '/customer/s/,\$/",/' | sed "s|^    }|    },|g" | sed "s|^}||g" | grep -v "^\$" > "\${SONARQUBE_METRICS_OUTPUT}"

echo -e "  \\"@last_analysis\\": [\\n    {\\n      \\"date\\": \\"\${SONARQUBE_LAST_ANALYSIS}\\"\\n    }\\n  ]\\n}" >> "\${SONARQUBE_METRICS_OUTPUT}"

# Send data to Elasticsearch

curl -k -s -X POST \${ELASTICSEARCH_URL}/sonarqube/_doc -H "Content-Type: application/json" -d @\${SONARQUBE_METRICS_OUTPUT}

            '''
        }
    }
}
