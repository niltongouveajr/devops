#!/usr/bin/env groovy

/**
 * For more information about this library, please see: https://gitlab.domain.local/shared/ci-utils/jenkins
 * Variables that need to be set for this lib to work correctly:
 * env.DeliveryEnvironment
 */

def call(){
    try {
        DeliveryEnvironment
    } catch (e) {
        throw new RuntimeException("Please ensure the " +
            "'env.DeliveryEnvironment' " +
            "variable must be set on your main Jenkinsfile")
    }
}

def call(DeliveryEnvironment) {
    if (env.DeliveryEnvironment == 'development') {
        echo "DevOps Metrics & KPIs - CD Env: ${DeliveryEnvironment}"
        sh("#!/bin/sh -e\n" + "echo \"DevOps Metrics & KPIs - Change Volume: \$(git --no-pager diff --shortstat HEAD^ HEAD)\"")
    }
    else if (env.DeliveryEnvironment == 'qa') {
        echo "DevOps Metrics & KPIs - CD Env: ${DeliveryEnvironment}"
        sh("#!/bin/sh -e\n" + "echo \"DevOps Metrics & KPIs - Change Volume: \$(git --no-pager diff --shortstat HEAD^ HEAD)\"")
    }
    else if (env.DeliveryEnvironment == 'homologation') {
        echo "DevOps Metrics & KPIs - CD Env: ${DeliveryEnvironment}"
        sh("#!/bin/sh -e\n" + "echo \"DevOps Metrics & KPIs - Change Volume: \$(git --no-pager diff --shortstat HEAD^ HEAD)\"")
    }
    else if (env.DeliveryEnvironment == 'staging') {
        echo "DevOps Metrics & KPIs - CD Env: ${DeliveryEnvironment}"
        sh("#!/bin/sh -e\n" + "echo \"DevOps Metrics & KPIs - Change Volume: \$(git --no-pager diff --shortstat HEAD^ HEAD)\"")
    }
    else if (env.DeliveryEnvironment == 'sit') {
        echo "DevOps Metrics & KPIs - CD Env: ${DeliveryEnvironment}"
        sh("#!/bin/sh -e\n" + "echo \"DevOps Metrics & KPIs - Change Volume: \$(git --no-pager diff --shortstat HEAD^ HEAD)\"")
    }
    else if (env.DeliveryEnvironment == 'production') {
        echo "DevOps Metrics & KPIs - CD Env: ${DeliveryEnvironment}"
        sh("#!/bin/sh -e\n" + "echo \"DevOps Metrics & KPIs - Change Volume: \$(git --no-pager diff --shortstat HEAD^ HEAD)\"")
    }
    else {
        echo "The variable 'DeliveryEnvironment' has an invalid value for the lib DeliveryTracking().\nAllowed values: development, qa, homologation, staging, sit, production"
        error "The variable 'DeliveryEnvironment' has an invalid value for the lib DeliveryTracking().\nAllowed values: development, qa, homologation, staging, sit, production"
    }
}
