# Jenkins Shared Libraries

Oftentimes it is useful to share parts of Pipelines between various projects to reduce redundancies and keep code "DRY".

Pipelines in Jenkins has support for creating "Shared Libraries" which can be defined in external source control repositories and loaded into existing Pipelines.

# Shared Libs

* [BuildJob()](#buildjob)
* [CheckOS()](#checkos)
* [CIFSPublisher()](#cifspublisher)
* [DotNETSwitchVersion()](#dotnetswitchversion)
* [DotNETSwitchVersionWin()](#dotnetswitchversionwin)
* [DownloadFile()](#downloadfile)
* [EmailNotification()](#emailnotification)
* [EmailNotificationDelivery()](#emailnotificationdelivery)
* [EmailNotificationPlain()](#emailnotificationplain)
* [EmailNotificationRelease()](#emailnotificationrelease)
* [EnvVarsDebug()](#envvarsdebug)
* [EnvVarsDebugWin()](#envvarsdebugwin)
* [EnvVarsDefault()](#envvarsdefault)
* [EnvVarsDefaultWin()](#envvarsdefaultwin)
* [FabricPublisher()](#fabricpublisher)
* [GitClone()](#gitclone)
* [HTMLPublisher()](#htmlpublisher)
* [JavaSwitchVersion()](#javaswitchversion)
* [JiraCreateIssueBuildStatus()](#jiracreateissuebuildstatus)
* [JiraGetIssueTransitions()](#jiragetissuetransitions)
* [JiraIntegratedVersion()](#jiraintegratedversion)
* [JiraIntegration()](#jiraintegration)
* [JiraIntegrationPlain()](#jiraintegrationplain)
* [JiraIssueTransitionOnly()](#jiraissuetransitiononly)
* [RancherChangeNodePort()](#rancherchangenodeport)
* [RancherCleanDeployment()](#ranchercleandeployment)
* [RancherDeploy()](#rancherdeploy)
* [RancherDeployCompose()](#rancherdeploycompose)
* [RancherDeployComposeAlternativeFile()](#rancherdeploycomposealternativefile)
* [RancherDeployDockerfile()](#rancherdeploydockerfile)
* [RancherDeployDockerfileOutsideContext()](#rancherdeploydockerfileoutsidecontext)
* [RancherDeployYAML()](#rancherdeployyaml)
* [SSHPublisher()](#sshpublisher)
* [SonarQube()](#sonarqube)
* [SonarQubeCoverage()](#sonarqubecoverage)
* [SonarQubeCoverageWin()](#sonarqubecoveragewin)
* [SonarQubeIssues()](#sonarqubeissues)
* [SonarQubeQualityGate()](#sonarqubequalitygate)
* [SonarQubeWin()](#sonarqubewin)
* [TeamsNotification()](#teamsnotification)
* [TeamsNotificationDelivery()](#teamsnotificationdelivery)
* [TeamsNotificationRelease()](#teamsnotificationrelease)
* [XcodeAvailableVersions()](#xcodeavailableversions) 
* [XcodeSwitchVersion()](#xcodeswitchversion) 
* [XrayImportResults()](#xrayimportresults)
* [ZipFile()](#zipfile) 


## BuildJob()

This lib is used to perform other job from the current job.

__Required Parameters:__

```
env.BuildJobName = "<job_name>"
env.BuildJobBranch = "<job_branch>"
```

__Usage Example:__

```
stage('Trigger Another Job') {
    steps {
        script {
            env.BuildJobName = "project_pipeline"
            env.BuildJobBranch = "master"
            BuildJob()
        }
    }
}
```

[:top:](#shared-libs)

## CheckOS()

This library is used to print on console the operating system used in the execution.

__Required Parameters:__

No required parameters.

__Usage Example:__

```
stage('Debug') {
    steps {
        CheckOS()
    }
}    
```

[:top:](#shared-libs)

## CIFSPublisher()

This library is used to transfer files to a Windows server using the CIFS protocol.

__Required Parameters:__

```
env.CIFSPublisherConfigName = "<config_name>"
env.CIFSPublisherExcludes = "<exclude_files_or_dir>"
env.CIFSPublisherRemoteDir = "<remote_dir>"
env.CIFSPublisherRemovePrefix = "<remove_prefix>"
env.CIFSPublisherSourceFiles = "<source_dir>"
```

__Usage Example:__

```
stage('CIFS publisher') {
    steps {
        script {
            env.CIFSPublisherConfigName = "sandbox-backend"
            env.CIFSPublisherExcludes = "**/*.dll"
            env.CIFSPublisherRemoteDir = "/srv/sbx/"
            env.CIFSPublisherRemovePrefix = "/libs"
            env.CIFSPublisherSourceFiles = "**/*"
            CIFSPublisher()
        }
    }
}    
```
[:top:](#shared-libs)

## DotNETSwitchVersion()

This lib is used to switch version of dotNET Core. It uses the script [dotnet-install.sh](https://docs.microsoft.com/en-us/dotnet/core/tools/dotnet-install-script) from Microsoft.

__Required Parameters:__

```
env.DotNETVersion = "<version>"
```

__Usage Example:__

```

...

stage('Something') {
    steps {
        script {
            env.DotNETVersion = "3.1"
            DotNETSwitchVersion()
        }
    }
}
```

[:top:](#shared-libs)

## DotNETSwitchVersionWin()

This lib is used to switch version of dotNET Core on Windows environment. It uses the script [dotnet-install.sh](https://docs.microsoft.com/en-us/dotnet/core/tools/dotnet-install-script) from Microsoft. In this lib for Windows, the installed dotnet binary will not be in the PATH environment variable and it is necessary to specify the full path for each dotnet command, as shown below.

__Required Parameters:__

```
env.DotNETVersion = "<version>"
```

__Usage Example:__

```

...

stage('Something') {
    steps {
        script {
            env.DotNETVersion = "3.1"
            DotNETSwitchVersionWin()
            bat "c:\dotnet\3.1\dotnet <command>"
        }
    }
}
```

[:top:](#shared-libs)

## DownloadFile()

This lib is used to download a file from an URL.

__Required Parameters:__

```
env.DownloadURL = "http://<web_page>"
env.DownloadDestination = "<destination>"
```

__Usage Example:__

```
...

env.DownloadURL = "https://devops.local/logo.png"
env.DownloadDestination = "logo.png"

...

stage('Download File') {
    steps {
        DownloadFile("${env.DownloadURl}", "${env.DownloadDestination}") (REVISAR!)
    }
}
```

[:top:](#shared-libs)

## EmailNotification()

This lib is used to send emails with build results.

__Required Parameters:__

```
env.EmailRecipients = "<notification_email_recipients>"
```

__Usage Example:__

```
...

env.EmailRecipients = "niltongouveajr@gmail.com"

...

post {
    failure {
        script {
            currentBuild.result = 'FAILURE'
        }
        EmailNotification()
    }
    success {
        script {
            currentBuild.result = 'SUCCESS'
        }
        EmailNotification()
    }
    changed {
        script {
            if (currentBuild.currentResult == 'SUCCESS') {
                currentBuild.result = 'SUCCESS'
                EmailNotification()
            }
        }
    }
}
```

__Result:__

![](images/EmailNotification.png)

[:top:](#shared-libs)

## EmalNotificationDelivery()

This lib is used to send emails when a delivery has been maid.

__Required Parameters:__

```
env.EmailRecipients = "<notification_email_recipients>"
```

__Usage Example:__

```
...

env.EmailRecipients = "niltongouveajr@gmail.com"

...

stage('Delivery to Prod') {
    steps {
        EmailNotificationDelivery()
    }
}
```

__Result:__

![](images/EmailNotificationDelivery.png)

[:top:](#shared-libs)

## EmailNotificationPlain() 

(DEPRECATED)

This lib is used to send emails with build results in text plain (not HTML).

__Required Parameters:__

```
env.EmailRecipients = "<notification_email_recipients>"
```

__Usage Example:__

```
...

env.EmailRecipients = "niltongouveajr@gmail.com"

...

post {
    failure {
        script {
            currentBuild.result = 'FAILURE'
        }
        EmailNotificationPlain()
    }
    success {
        script {
            currentBuild.result = 'SUCCESS'
        }
        EmailNotificationPlain()
    }
    changed {
        script {
            if (currentBuild.currentResult == 'SUCCESS') {
                currentBuild.result = 'SUCCESS'
                EmailNotificationPlain()
            }
        }
    }
}
```

[:top:](#shared-libs)

## EmailNotificationRelease()

This lib is used to send emails when a release has been maid.

__Required Parameters:__

```
env.EmailRecipients = "<notification_email_recipients>"
```

__Usage Example:__

```
...

env.EmailRecipients = "niltongouveajr@gmail.com"

...

stage('Release to Prod') {
    steps {
        EmailNotificationRelease()
    }
}
```

[:top:](#shared-libs)

## EnvVarsDebug()

This lib is used to print on console all environment variables for debug purpose.

__Required Parameters:__

No required parameters.

__Usage Example:__

```
environment {
    ENV_VARS_DEBUG = EnvVarsDebug() 
}
```

[:top:](#shared-libs)

## EnvVarsDebugWin()

This lib is used to print on console all environment variables for debug purpose.

__Required Parameters:__

No required parameters.

__Usage Example:__

```
environment {
    ENV_VARS_DEBUG = EnvVarsDebugWin() 
}
```

[:top:](#shared-libs)

## EnvVarsDefault()

This lib is used to set most common environment variables (ANDROID_HOME, JAVA_HOME, PATH, etc) on Linux or Mac operating systems.

__Required Parameters:__

No required parameters.

__Usage Example:__

```
environment {
    ENV_VARS_DEFAULT = EnvVarsDefault()
}

```

[:top:](#shared-libs)

## EnvVarsDefaultWin()

This lib is used to set most common environment variables (ANDROID_HOME, JAVA_HOME, PATH, etc) on Windows operating system.

__Required Parameters:__

No required parameters.

__Usage Example:__

```
environment {
    ENV_VARS_DEFAULT_WIN = EnvVarsDefaultWin()
}

```

[:top:](#shared-libs)

## FabricPublisher()

This lib is used to publish mobile artifacts (APK, IPA) in Fabric.

__Required Parameters:__

```
env.FabricAPIKey = "<api_key>"
env.FabricAPKPath = "<apk_path_dir>"
env.FabricBuildSecret = "<bild_secret_hash>"
env.FabricOrganization = "<organization>"
env.FabricTestersEmails = "<testers_email_recipients>"
```

__Usage Example:__

```
...

env.FabricAPIKey = "abcdefghijklmnopqrstuvwxyz1234567890"
env.FabricAPKPath = "app/build/outputs/apk/prod/release/*.apk"
env.FabricBuildSecret = "abcdefghijklmnopqrstuvwxyz1234567890"
env.FabricOrganization = "Venturus"
env.FabricTestersEmails = "devops-testers@local"

...

stage('Release to QA') {
    steps {
        dir(BuildPath) {
            script {
                FabricPublisher()
            }
        }
    } 
}
```

[:top:](#shared-libs)

## GitClone()

This lib is used to clone a Git repository, usually hosted on corporate Gitlab.

__Required Parameters:__

```
env.GitURL = "https://gitlab.local/<project_customer>/<project_name>/<repository_name>"
env.GitCredentials = "<git_credentials>"
```

__Usage Example:__

```
...

env.GitURL = "https://gitlab.local/devops/site"
env.GitCredentials = "secret"

...

stage('Prepare') {
    steps {
        GitClone()
    }
}
```

[:top:](#shared-libs)

## HTMLPublisher()

This lib is used to publish HTML reports in Jenkins.

__Required Parameters:__

```
env.HTMLAllowMissing = "<true|false>"
env.HTMLReportDir = "<html_path_dir>"
env.HTMLReportFiles = "<html_filename>"
env.HTMLReportName = "<html_report_name>"
```

__Usage Example:__

```
stage('Unitary Tests') {
    steps {
        dir(BuildPath) {
            script{
                env.HTMLAllowMissing = "false"
                env.HTMLReportDir = "app/build/reports/tests"
                env.HTMLReportFiles = "index.html"
                env.HTMLReportName = "DevOps Unitary Tests Report"
                HTMLPublisher()
            }
        }
    }
}    
```

[:top:](#shared-libs)

## JavaSwitchVersion()

This lib is used to select Java JDK version.

__Required Parameters:__

```
env.JdkVersion = "<number>"
```

__Usage Example:__

```
...

// Tools Variables
env.JdkVersion = "11"

...

tools {
    jdk "jdk${JdkVersion}"
}

...

stage('Select Java Version') {
    script{
        JavaSwitchVersion()
    }
}
```

[:top:](#shared-libs)

## JiraCreateIssueBuildStatus()

This lib is used to create an issue in Jira. Useful for automatically create tasks or bugs based on build status.

__Required Parameters:__

```
env.JiraKey = "<jira_key>"
env.JiraSummary = "<jira_summary>"
env.JiraDescription = "<jira_description>"
env.JiraIssueType = "<jira_issueType>"
```

__Usage Example:__

```
...
post {
    failure {
        script {
            currentBuild.result = 'FAILURE'
            env.JiraKey = "DEVOPS"
            env.JiraSummary = "Pipeline Status: ${currentBuild.result}"
            env.JiraDescription = "Please check"
            env.JiraIssueType = "Task"
            JiraCreateIssueBuildStatus()
        }
    }
}
```

__Result:__

```
JIRA: Site - Jira Corporativo - Creating new issue: IssueInput(update=null, fields={project={key=DEVOPS}, summary=Pipeline Status: FAILURE, description=Please check
Successful. Code: 201
DEVOPS-482
```

[:top:](#shared-libs)

## JiraGetIssueTransitions()

This lib is used to get Jira internal transition id for an specific issue.

__Required Parameters:__

```
env.JiraIssue = "<jira_issue>"
```

__Usage Example:__

```
...

stage('Get Jira transition ID') {
    steps {
        script{
            env.JiraIssue = "DEVOPS-248"
            JiraGetIssueTransitions()
        }
    }
}
```

__Result:__

```
JIRA: Site - Jira Corporativo - Querying issue transitions with idOrKey: DEVOPS-248
Successful. Code: 200
[Pipeline] echo
[expand:transitions, transitions:[[id:31, name:Close, to:[self:https://jira.local/rest/api/2/status/10001, description:, iconUrl:https://jira.local/, name:Done, id:10001, statusCategory:[self:https://jira.local/rest/api/2/statuscategory/3, id:3, key:done, colorName:green, name:Done]], fields:[:]], [id:51, name:Cancel, to:[self:https://jira.local/rest/api/2/status/10105, description:, iconUrl:https://jira.local/images/icons/status_generic.gif, name:Canceled, id:10105, statusCategory:[self:https://jira.local/rest/api/2/statuscategory/3, id:3, key:done, colorName:green, name:Done]], fields:[:]], [id:71, name:Rollback, to:[self:https://jira.local/rest/api/2/status/1, description:The issue is open and ready for the assignee to start work on it., iconUrl:https://jira.local/images/icons/statuses/open.png, name:Open, id:1, statusCategory:[self:https://jira.local/rest/api/2/statuscategory/2, id:2, key:new, colorName:blue-gray, name:To Do]], fields:[:]]]]
```

[:top:](#shared-libs)

## JiraIntegratedVersion()

This lib is used to create a version in Jira, change issues status from JQL query to custom transition id (see: [JiraGetIssueTransitions()](#jiragetissuetransitions)), change field "Integrated Version" filling it with tag name and send an notification email with the issue that are part of this release.

__Required Parameters:__

```
env.JiraKey = "<jira_key>"
env.JiraJQL = "<jql_expression>"
env.JiraTransitionId = "<transition_id>"
```

__Usage Example:__

```
...

env.JiraKey = "SITE"
env.JiraJQL = "PROJECT = '${JiraKey}' and (status = Finished and (issuetype = Bug OR issuetype = Improvement OR issuetype = Story) or (issuetype = Story and status = Done)) and Sprint in openSprints() and created > startOfYear() and 'Integrated Version' is EMPTY ORDER BY Rank ASC"
env.JiraTransitionId = "201"

...

stage('Release to QA') {
    steps {
        JiraIntegratedVersion()
    }
}
```

__Result:__

![](images/JiraIntegratedVersion.png)


[:top:](#shared-libs)


## JiraIntegration()

This lib is used to create a version in Jira, change issues status from "Finished" to "Ready for Validation", change field "Integrated Version" filling it with released version and send email notification with the issue that are part of this release.

__Required Parameters:__

```
env.BuildProject = "<build_project>"
env.BuildVersion = "<build_version_number>"
env.JiraKey = "<jira_key>"
env.JiraJQL = "<jql_expression>"
```

__Usage Example:__

```
...

env.BuildProject = "site"
env.BuildVersion = "1.0.${env.BUILD_NUMBER}"
env.JiraKey = "SITE"
env.JiraJQL = "PROJECT = '${JiraKey}' and (status = Finished and (issuetype = Bug OR issuetype = Improvement OR issuetype = Story) or (issuetype = Story and status = Done)) and Sprint in openSprints() and created > startOfYear() and 'Integrated Version' is EMPTY ORDER BY Rank ASC"

...

stage('Release to QA') {
    steps {
        JiraIntegration()
    }
}
```

[:top:](#shared-libs)

## JiraIntegrationPlain()

This lib is used to create a version in Jira, change issues status from "Finished" to "Ready for Validation", change field "Integrated Version" filling it with released version and send text email notification with the issue that are part of this release.

__Required Parameters:__

```
env.BuildName = "<build_name>"
env.BuildVersion = "<build_version_number>"
env.JiraKey = "<jira_key>"
env.JiraJQL = "<jql_expression>"
```

__Usage Example:__

```
...

env.BuildName = "site"
env.BuildVersion = "1.0.${env.BUILD_NUMBER}"
env.JiraKey = "SITE"
env.JiraJQL = "PROJECT = '${JiraKey}' and (status = Finished and (issuetype = Bug OR issuetype = Improvement OR issuetype = Story) or (issuetype = Story and status = Done)) and Sprint in openSprints() and created > startOfYear() and 'Integrated Version' is EMPTY ORDER BY Rank ASC"

...

stage('Release to QA') {
    steps {
        JiraIntegration()
    }
}
```

## JiraIssueTransitionOnly()

This lib change issues status from JQL query to custom transition id (see: [JiraGetIssueTransitions()](#jiragetissuetransitions)) and send a notification email.

__Required Parameters:__

```
env.JiraKey = "<jira_key>"
env.JiraJQL = "<jql_expression>"
env.JiraTransitionId = "<transition_id>"
```

__Usage Example:__

```
...

env.JiraKey = "SITE"
env.JiraJQL = "PROJECT = '${JiraKey}' and (status = Finished and (issuetype = Bug OR issuetype = Improvement OR issuetype = Story) or (issuetype = Story and status = Done)) and Sprint in openSprints() and created > startOfYear() and 'Integrated Version' is EMPTY ORDER BY Rank ASC"
env.JiraTransitionId = "201"

...

stage('Release to QA') {
    steps {
        JiraIssueTransitionOnly()
    }
}
```

[:top:](#shared-libs)

## RancherChangeNodePort()

This lib is used to change exposed port for an application deployed in Rancher.

__Required Parameters:__

```
env.RancherDeployment = "<deployment>"
env.RancherNamespace = "<namespace>"
env.RancherNodePort = "<port>"
```

__Usage Example:__

```
...
env.RancherDeployment = "site"
env.RancherNamespace = "devops-site"
env.RancherNodePort = "31234"


...

stage('Rancher') {
    steps {
        RancherChangeNodePort("${env.RancherDeployment}", "${env.RancherNamespace}", "${env.RancherNodePort}" )
    }
}
```
[:top:](#shared-libs)

## RancherCleanDeployment()

This lib is used to cleanup Kubernetes deployment before deploy using other Rancher libs.

__Required Parameters:__

```
env.RancherUser = "<user>"
env.RancherToken = "<auth_token>"
env.RancherCluster = "<cluster_name>"
env.RancherServer = "<server>"
env.RancherNamespace = "<namespace>"
env.RancherSecret = "<secret>"
env.RancherDeployment = "<deployment>"
```

__Usage Example:__

```
...

env.RancherUser = "user-123abc"
env.RancherToken = "kubeconfig-user-gmcnb:abcdefghijklmnopqrstuvwxyz1234567890"
env.RancherCluster = "venturus"
env.RancherServer = "https://rancher.local/k8s/clusters/c-rsfp9"
env.RancherNamespace = "devops-site"
env.RancherSecret = "devops-hosted"
env.RancherDeployment = "site"

...

stage('Release to QA') {
    steps {
        RancherCleanDeployment()
    }
}
```

[:top:](#shared-libs)

## RancherDeploy()

This lib is used to redeploy the same version or new version of a pod (deployment) in Rancher.

__Required Parameters:__

```
env.RancherCredential = "<credential-id>"
env.RancherDockerRegistryImage = "<image>"
env.RancherDockerRegistryImageVersion = "<version>"
env.RancherProject = "<project-id>"
env.RancherNamespace = "<namespace>"
env.RancherDeployment = "<deployment>"
```

__Usage Example:__

```
...

stage('Deploy to Dev') {
    steps {
        script {
            env.RancherCredential = "vntdevops"
            env.RancherDockerRegistryImage = "docker.local:5000/busybox"
            env.RancherDockerRegistryImageVersion = "latest"
            env.RancherProject = "p-khm62"
            env.RancherNamespace = "devops-sandbox-development"
            env.RancherDeployment = "busybox"
            RancherDeploy()
        }
    }
}
```

[:top:](#shared-libs)

## RancherDeployCompose()

This lib is used to make a deploy in Rancher through a Docker Compose configuration file.

__Required Parameters:__

```
env.RancherUser = "<user>"
env.RancherToken = "<auth_token>"
env.RancherCluster = "<cluster_name>"
env.RancherServer = "<server>"
env.RancherNamespace = "<namespace>"
env.RancherSecret = "<secret>"
env.RancherDeployment = "<deployment>"
env.RancherComposeFile = "<compose_file>"
```

__Usage Example:__

```
...

env.RancherUser = "user-123abc"
env.RancherToken = "kubeconfig-user-gmcnb:abcdefghijklmnopqrstuvwxyz1234567890"
env.RancherCluster = "venturus"
env.RancherServer = "https://rancher.local/k8s/clusters/c-rsfp9"
env.RancherNamespace = "devops-site"
env.RancherSecret = "devops-hosted"
env.RancherDeployment = "site"
env.RancherComposeFile = "docker-compose.yml"

...

stage('Deploy to QA') {
    steps {
        RancherDeployCompose()
    }
}
```

[:top:](#shared-libs)

## RancherDeployComposeAlternativeFile()

This lib is used to make a deploy in Rancher through a Docker Compose configuration file.

__Required Parameters:__

```
env.RancherUser = "<user>"
env.RancherToken = "<auth_token>"
env.RancherCluster = "<cluster_name>"
env.RancherServer = "<server>"
env.RancherNamespace = "<namespace>"
env.RancherSecret = "<secret>"
env.RancherComposeFile = "<compose_file>"
```

__Usage Example:__

```
...

env.RancherUser = "user-123abc"
env.RancherToken = "kubeconfig-user-gmcnb:abcdefghijklmnopqrstuvwxyz1234567890"
env.RancherCluster = "venturus"
env.RancherServer = "https://rancher.local/k8s/clusters/c-rsfp9"
env.RancherNamespace = "devops-site"
env.RancherSecret = "devops-hosted"
env.RancherComposeFile = "docker-compose.yml"

...

stage('Deploy to QA') {
    steps {
        RancherDeployComposeAlternativeFile()
    }
}
```
[:top:](#shared-libs)

## RancherDeployDockerfile()

This lib is used to make a deploy in Rancher through a Dockerfile.

__Required Parameters:__

```
env.RancherUser = "<user>"
env.RancherToken = "<auth_token>"
env.RancherCluster = "<cluster_name>"
env.RancherServer = "<server>"
env.RancherNamespace = "<namespace>"
env.RancherSecret = "<secret>"
env.RancherDeployment = "<deployment>"
env.RancherDockerRegistryImage = "<image_path_and_name>"
env.RancherDockerRegistryImageVersion = "<image_version>"
env.RancherDockerInternalPort = "<internal_port>"

```

__Usage Example:__

```
...

env.RancherUser = "user-123abc"
env.RancherToken = "kubeconfig-user-gmcnb:abcdefghijklmnopqrstuvwxyz1234567890"
env.RancherCluster = "venturus"
env.RancherServer = "https://rancher.local/k8s/clusters/c-rsfp9"
env.RancherNamespace = "devops-site"
env.RancherSecret = "devops-hosted"
env.RancherDeployment = "site"
env.RancherDockerRegistryImage = "docker.local:5000/site/frontend"
env.RancherDockerRegistryImageVersion = "1.0"
env.RancherDockerInternalPort = "80"

...

stage('Deploy to QA') {
    steps {
        RancherDeployDockerfile()
    }
}
```

[:top:](#shared-libs)

## RancherDeployDockerfileOutsideContext()

This lib is used to make a deploy in Rancher through a Dockerfile without necessity of the file be in same directory.

__Required Parameters:__

```
env.RancherUser = "<user>"
env.RancherToken = "<auth_token>"
env.RancherCluster = "<cluster_name>"
env.RancherServer = "<server>"
env.RancherNamespace = "<namespace>"
env.RancherSecret = "<secret>"
env.RancherDeployment = "<deployment>"
env.RancherDockerRegistryImage = "<image_path_and_name>"
env.RancherDockerRegistryImageVersion = "<image_version>"
env.RancherDockerInternalPort = "<internal_port>"

```

__Usage Example:__

```
...

env.RancherUser = "user-123abc"
env.RancherToken = "kubeconfig-user-gmcnb:abcdefghijklmnopqrstuvwxyz1234567890"
env.RancherCluster = "venturus"
env.RancherServer = "https://rancher.local/k8s/clusters/c-rsfp9"
env.RancherNamespace = "devops-site"
env.RancherSecret = "devops-hosted"
env.RancherDeployment = "site"
env.RancherDockerRegistryImage = "docker.local:5000/site/frontend"
env.RancherDockerRegistryImageVersion = "1.0"
env.RancherDockerInternalPort = "80"

...

stage('Deploy to QA') {
    steps {
        RancherDeployDockerfileOutsideContext()
    }
}
```

[:top:](#shared-libs)

## RancherDeployYAML()

This lib is used to make a deploy in Rancher through a YAML file.

__Required Parameters:__

```
env.RancherUser = "<user>"
env.RancherToken = "<auth_token>"
env.RancherCluster = "<cluster_name>"
env.RancherServer = "<server>"
env.RancherNamespace = "<namespace>"
env.RancherSecret = "<secret>"
env.RancherDeployment = "<deployment>"
env.RancherDockerRegistryImage = "<image_path_and_name>"
env.RancherDockerRegistryImageVersion = "<image_version>"
env.RancherDockerInternalPort = "<internal_port>"
env.RancherYAMLFile = "<yaml_filename>"

```

__Usage Example:__

```
...

env.RancherUser = "user-123abc"
env.RancherToken = "kubeconfig-user-gmcnb:abcdefghijklmnopqrstuvwxyz1234567890"
env.RancherCluster = "venturus"
env.RancherServer = "https://rancher.local/k8s/clusters/c-rsfp9"
env.RancherNamespace = "devops-site"
env.RancherSecret = "devops-hosted"
env.RancherDeployment = "site"
env.RancherDockerRegistryImage = "docker.local:5000/site/frontend"
env.RancherDockerRegistryImageVersion = "1.0"
env.RancherDockerInternalPort = "80"
env.RancherYAMLFile = "YAMLfile"

...

stage('Deploy to QA') {
    steps {
        RancherDeployYAML()
    }
}
```

[:top:](#shared-libs)

## SSHPublisher()

This library is used to transfer files to a Linux server using the SSH protocol.

__Required Parameters:__

```
env.SSHPublisherConfigName = "<config_name>"
env.SSHPublisherExcludes = "<files_exclude>"
env.SSHPublisherExec = "<command_to_executation>"
env.SSHPublisherRemoteDir = "<remote_dir_name>"
env.SSHPublisherRemovePrefix = "<prefix_to_remove>"
env.SSHPublisherSourceFiles = "<source_path>"
```

__Usage Example:__

```
...

env.SSHPublisherConfigName = "devops_site"
env.SSHPublisherExcludes = "**/*.dll"
env.SSHPublisherExec = "ls /srv/devops/site"
env.SSHPublisherRemoteDir = "/srv/devops/site"
env.SSHPublisherRemovePrefix = "/srv/devops/site"
env.SSHPublisherSourceFiles = "."

...

stage('Delivery to Development') {
    steps {
        SSHPublisher()
    }
}
```

[:top:](#shared-libs)

## SonarQube()

This lib is used to perform SonarQube static code analysis.

__Required Parameters:__

```
env.SonarRunnerVersion = "<runner_version>"
env.SonarVersion = "<version>"

```

__Usage Example:__

```
...

env.SonarRunnerVersion = "3.0.3"
env.SonarVersion = "6.7.1"

...

stage('Static Analysis') {
    steps {
        script {
            if (fileExists ('sonar-project.properties')) {
                SonarQube()
            }
        }
    }
}
```

[:top:](#shared-libs)

## SonarQubeCoverage()

(DEPRECATED! Please use library SonarQubeQualityGate as an alternative)

This lib is used to broken build if is not conform with the minimal coverage defined.

__Required Parameters:__

```
env.SonarURL = "url_server>"
env.SonarLogin = "<auth_token>"
env.SonarProjectKey = "<project_key>"
env.SonarMinPercentage = "<coverage_percent_minimal>"
```

__Usage Example:__

```
...

env.SonarURL = "https://sonar.local"
env.SonarLogin = "abcdefghijklmnopqrstuvwxyz134567890"
env.SonarProjectKey = "DEVS"
env.SonarMinPercentage = "30"

...

stage('Static Analysis') {
    steps {
        script {
            SonarQubeCoverage()
        }
    }
}
```

[:top:](#shared-libs)

## SonarQubeCoverageWin()

This lib is used to perform SonarQube static code analysis in Windows environment publishing test reports results.

__Required Parameters:__

```
env.MSBuildSolution = "<msbuild_solution_file>"
env.SonarProjectKey = "<project_key>"
env.SonarExclusions = "<exclusions_files>"
env.SonarRunnerVersion = "<runner_version>"
env.SonarVersion = "<version>"
env.SonarTestsDLLFile = "<teste_dll_file>"
env.SonarTestsReportPath = "<test_report_file>"
```

__Usage Example:__

```
...

env.MSBuildSolution = "devops_site.sln"
env.SonarProjectKey = "DEVS"
env.SonarExclusions = "**/*.css,**/*.js"
env.SonarRunnerVersion = "3.0.3"
env.SonarVersion = "6.7.1"
env.SonarTestsDLLFile = "<teste_dll_file>"
env.SonarTestsReportPath = "<test_report_file>"

...

stage('Static Analysis') {
    steps {
        script {
            if (fileExists ('sonar-project.properties')) {
                SonarQubeCoverageWin()
            }    
        }
    }
}
```

[:top:](#shared-libs)

## SonarQubeIssues()

(DEPRECATED! Please use library SonarQubeQualityGate as an alternative)

This lib is used to broken build if the build have critical issues on SonarQube.

__Required Parameters:__

```
env.SonarURL = "<url>"
env.SonarLogin = "<auth_login>"
env.SonarProjectKey = "<project_key>"
```

__Usage Example:__

```
...

env.SonarURL = "https://sonar.local"
env.SonarLogin = "abcdefghijklmnopqrstuvwxyz134567890"
env.SonarProjectKey = "DEVS"

...

stage('Static Analysis') {
    steps {
        script {
            SonarQubeIssues()
        }
    }
}
```

[:top:](#shared-libs)

## SonarQubeQualityGate()

This lib is used to broken build if the code does not conform with the SonarQube rules.


> It replaces the deprecated libs: SonarQubeCoverage() and SonarQubeIssues() 

__Required Parameters:__

No required parameters.

__Usage Example:__

```
stage('Static Analysis') {
    steps {
        script {
            if (fileExists ('sonar-project.properties')) {
                SonarQubeQualityGate()
            }    
        }
    }
}
```

[:top:](#shared-libs)

## SonarQubeWin()

This lib is used to perform SonarQube static code analysis in Windows environment.

__Required Parameters:__

```
env.BuildPath = "<build_path>"
env.MSBuildSolution = "<msbuild_solution>"
env.SonarProjectKey = "<project_key>"
env.SonarExclusions = "<exclusions>"
env.SonarRunnerVersion = "<runner_version>"
env.SonarVersion = "<version>"
```

__Usage Example:__

```
...

env.BuildPath = "."
env.MSBuildSolution = "devops_site.sln"
env.SonarProjectKey = "DEVS"
env.SonarExclusions = "**/*.css,**/*.js"
env.SonarRunnerVersion = "3.0.3"
env.SonarVersion = "6.7.1"

...

stage('Static Analysis') {
    steps {
        script {
            if (fileExists ('sonar-project.properties')) {
                SonarQubeWin() // Performs sonar-scanner
            }
        }
    }
}
```

[:top:](#shared-libs)

## TeamsNotification()

This lib is used to send a build results in a Microsoft Teams channel.

__Required Parameters:__

```
env.TeamsWebHook = "<notification_teams_webhook>"
```

__Usage Example:__

```
...

env.TeamsWebHook = "https://outlook.office.com/webhook/f3eda2fa-83d1-46b7-86b9-665522e7b0dd@f4d16f32-3894-45d2-aa43-4998abfff44c/JenkinsCI/40badbb63fdc4f27b5fcf47393bfc4dc/b0b191c5-edb3-4798-acd9-e5f67348855f"

...

post {
    failure {
        script {
            currentBuild.result = 'FAILURE'
        }
        TeamsNotification()
    }
    success {
        script {
            currentBuild.result = 'SUCCESS'
        }
        TeamsNotification()
    }
    changed {
        script {
            if (currentBuild.currentResult == 'SUCCESS') {
                currentBuild.result = 'SUCCESS'
                TeamsNotification()
            }
        }
    }
}
```

[:top:](#shared-libs)

## TeamsNotificationDelivery()

This lib is used to send a build results in a Microsoft Teams channel when a delivery has been maid.

__Required Parameters:__

```
env.TeamsWebHook = "<notification_teams_webhook>"
```

__Usage Example:__

```
...

env.TeamsWebHook = "https://outlook.office.com/webhook/f3eda2fa-83d1-46b7-86b9-665522e7b0dd@f4d16f32-3894-45d2-aa43-4998abfff44c/JenkinsCI/40badbb63fdc4f27b5fcf47393bfc4dc/b0b191c5-edb3-4798-acd9-e5f6734885"

...

stage('Delivery to Prod') {
    steps {
        TeamsNotificationDelivery()
    }
}
```

[:top:](#shared-libs)

## TeamsNotificationRelease()

This lib is used to send a build results in a Microsoft Teams channel when a release has been maid.

__Required Parameters:__

```
env.TeamsWebHook = "<notification_teams_webhook>"
```

__Usage Example:__

```
...

env.TeamsWebHook = "https://outlook.office.com/webhook/f3eda2fa-83d1-46b7-86b9-665522e7b0dd@f4d16f32-3894-45d2-aa43-4998abfff44c/JenkinsCI/40badbb63fdc4f27b5fcf47393bfc4dc/b0b191c5-edb3-4798-acd9-e5f6734885"

...

stage('Delivery to Prod') {
    steps {
        TeamsNotificationRelease()
    }
}
```

[:top:](#shared-libs)

## XcodeAvailableVersions()

This lib is used to show Xcode availables versions in Jenkins slave.

__Required Parameters:__

No required parameters.

__Usage Example:__

```
stage('Prepare') {
    steps {
        XcodeAvailableVersions()
    }
}
```

[:top:](#shared-libs)

## XcodeSwitchVersion()

This lib is used to switch a Xcode version in Jenkins slave.

__Required Parameters:__

```
env.XcodeVersion = "<xcode_version>"
```

__Usage Example:__

```
...

env.XcodeVersion = "10.1"

...

stage('Prepare') {
    steps {
        XcodeSwitchVersions()
    }
}
```

[:top:](#shared-libs)

## XrayImportResults()

This lib is used to import test results to Jira Xray test issues. 

__Required Parameters:__

```
env.XrayEndPointName  = "endpoint_name"
env.XrayImportFilePath = "import_file_path"
env.XrayJiraKey = "${env.JiraKey}"
env.XrayRevision = "${env.JiraKey}-${env.BuildVersion}"
env.XrayTestEnvironments = "test_environments"
```

__Usage Example:__

```
stage('Import Execution Results to XRay') {
    steps {
        script {
            env.XrayEndPointName = "/junit"
            env.XrayImportFilePath = "app/build/outputs/androidTest-results/connected/flavors/MOCK/*.xml"
            env.XrayJiraKey = "${env.JiraKey}"
            env.XrayRevision = "${env.JiraKey}-${env.BuildVersion}"
            env.XrayTestEnvironments = "Mock"
            XrayImportResults()
        }
    }
}
```

[:top:](#shared-libs)

## ZipFile()

This lib is used to make a zip from a directory or file.

__Required Parameters:__

No required parameters.

__Usage Example:__

```
stage('Package') {
    steps {
        ZipFile("<source_files>", "<destination_files>", "<ignore_files>" )
    }
}
```
[:top:](#shared-libs)
