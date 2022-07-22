#!/usr/bin/env groovy

/**
 * For more information about this library, please see: https://gitlab.domain.local/shared/ci-utils/jenkins
 * Variables that need to be set for this lib to work correctly:
 * env.EmailRecipients
 */


def call() {
    try {
        EmailRecipients
    } catch (e) {
        throw new RuntimeException("Please ensure the " +
            "'env.EmailRecipients' " +
            "variable is defined on your main Jenkinsfile")
    }
    if (isUnix()) {
        sh 'wget -q https://devops.domain.local/downloads/others/email/logo_header.png -O logo_header.png --no-check-certificate'
        sh 'wget -q https://devops.domain.local/downloads/others/email/logo_footer.png -O logo_footer.png --no-check-certificate'
    } else {
        EnvVarsDefaultWin()
        bat 'wget -q https://devops.domain.local/downloads/others/email/logo_header.png -O logo_header.png --no-check-certificate'
        bat 'wget -q https://devops.domain.local/downloads/others/email/logo_footer.png -O logo_footer.png --no-check-certificate'
    }
    def EmailContent = """
<!doctype html>
<html>
<head>
    <meta name="viewport" content="width=device-width">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>VNT.DevOps - VSDT - Ferramentas de Suporte ao Desenvolvimento</title>

    <style>
        a {
            color: #ED1B66;
        }
    </style>
    
</head>

<body bgcolor="#f6f6f6" link="#ED1B66" vlink="#ED1B66">

    <table border="0" cellpadding="0" cellspacing="0" width="100%" style="border: 1px solid lightgray; background-color: #FFF;" align="center">
    <tr>
        <td class="header-section" style="border-bottom: 1px solid #999999;background-image: linear-gradient(to right, #532d8c 0%, #ed1b66 100%);background-color: #542D8C;background-size:contain;height: 80px;width: 105%;vertical-align: middle;padding-top: 10px;padding-left: 22px;">
            <img src="cid:logo_header.png">
        </td>
    </tr>
    <tr>
        <td >
            <table style="margin: 25px;">
                <tr>
                    <td>
                        <h2 style="font-family: verdana, sans-serif;color: #888;font-weight: bolder;font-size: 14pt;margin: 0;padding: 0;margin:0;mso-line-height-rule:exactly;">
                            DevOps
                        </h2>
                        <h3 style="font-family: verdana, sans-serif;color: #2E2E2E;font-weight: bolder;font-size: 32pt;margin: 0;padding: 0;margin-bottom: 30px;margin:0;mso-line-height-rule:exactly;">
                            Jenkins
                        </h3>
                    </td>
                </tr>
                <tr>
                    <td>
                        <p style="font-family: verdana, helvetica, sans-serif; margin-top: 0px;">
                            <br>  
                            Hello!
                            <br>  
                            <br>  
                             A new build for <b><span style="color:#ED1B66">${env.JOB_NAME}</span></b> has been performed:  <b><span style="color:#ED1B66">#${env.BUILD_NUMBER}</span></b>.
                            <br>  
                            <br>  
                            <table style="width: 100%; height: 30px;" border="0" cellpadding="0" cellspacing="0" height="30" >
                                <tr>
                                    <td style="width: 5px; background-color: #ed1b66;">
                                        &nbsp;
                                    </td>
                                    <td style="background-color: #fde8f0; padding: 10px; font-family: verdana, Helvetica, sans-serif">
                                        Status is: <b><span style="color:#ED1B66">$currentBuild.result</span></b>
                                    </td>
                                </tr>
                            </table>
                            <br>  
                            You can check the build results and the current status at:
                            <br>
                            <br>
                            <b><a href="${env.BUILD_URL}console" style="text-decoration:none;"><span style="color:#ED1B66"><u>${env.BUILD_URL}console</u></a></span></b>
                            <br>
                            <br>
                            You are receiving this email from Jenkins because you're either on a notification list or you commited some code to a project being built by Jenkins. If you do not want to receive this email, please let us know.
                        </p>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr>
        <td>
            <table border="0" cellpadding="0" cellspacing="0" width="100%" style="margin: 20px;magin-top: 0px;width: 100%;font-family: verdana, sans-serif;">
                <tbody>
                    <tr>
                        <td valign="top" width="90" style="padding: 8px;text-align: left;">
                            <img src="cid:logo_footer.png"
                                width="90" height="70" alt="DevOps" style="border: 0;max-width: 100%;height: auto;">
                            <br>
                        </td>
                        <td valign="top" style="padding: 8px;text-align: left;">
                            <span style="font-family:Helvetica,Calibri,Candara,Segoe,Segoe UI,Optima,verdana,sans-serif;">
                                <span style="color:#181818; font-size: 14px; line-height: 18px;">
                                    <b style="font-weight: bold;">Jenkins</b>
                                </span>
                                <br>
                                <span style="color:#e81a67; font-size: 12px;">DEVOPS TEAM</span>
                                <br>
                                <a style="color: #999999;font-size: 12px;background-color: transparent;transition: color 0.2s ease;" href="https://www.domain.local"
                                    target="_blank">
                                    <b style="font-weight: bold;">domain.local</b>
                                </a>
                                <br>
                                <span style="color:#BBBBBB; font-size: 9px;">DEVELOPING THE FUTURE</span>
                            </span>
                        </td>
                    </tr>
                </tbody>
            </table>
        </td>
    </tr>
</table>
</body>
</html>
"""
    emailext (
        attachmentsPattern: "logo_header.png,logo_footer.png",
        to: "\$DEFAULT_RECIPIENTS,${EmailRecipients}",
        replyTo: 'noreply@domain.local',
        subject: "[VNT.DevOps] ${env.JOB_NAME} (#${env.BUILD_NUMBER}) ~ $currentBuild.result",
        body: "${EmailContent}",
        mimeType: 'text/html',
        recipientProviders: [
//          [$class: 'DevelopersRecipientProvider'],
            [$class: 'CulpritsRecipientProvider'],
            [$class: 'RequesterRecipientProvider']
        ]
    )
}
