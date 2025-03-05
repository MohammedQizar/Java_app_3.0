@Library('my-shared-library') _

pipeline {
    agent any
    // agent { label 'Demo' }

    parameters {
        choice(name: 'action', choices: ['create', 'delete'], description: 'Choose create/Destroy')
        string(name: 'ImageName', description: "name of the docker build", defaultValue: 'javapp')
        string(name: 'ImageTag', description: "tag of the docker build", defaultValue: 'v1')
        string(name: 'DockerHubUser', description: "name of the Application", defaultValue: 'mohammedqizar')
        string(name: 'WarFilePath', description: "Path to the WAR file", defaultValue: 'target/kubernetes-configmap-reload-0.0.1-SNAPSHOT.war')
        string(name: 'TomcatContainerName', description: "Name of the Tomcat Docker container", defaultValue: 'tomcat-container')
        string(name: 'TomcatHost', description: "Tomcat server host address", defaultValue: '18.144.1.181')
        string(name: 'TomcatPort', description: "Tomcat server port", defaultValue: '8080') // Port is now 8081 for Tomcat
        string(name: 'TomcatUser', description: "Tomcat username", defaultValue: 'admin')
        string(name: 'TomcatPassword', description: "Tomcat password", defaultValue: 'admin')
    }
 environment {
        TOMCAT_URL = "http://${params.TomcatHost}:${params.TomcatPort}/manager/text/deploy"
    }

    stages {
        stage('Git Checkout') {
            when { expression { params.action == 'create' } }
            steps {
                gitCheckout(
                    branch: "main",
                    url: "https://github.com/MohammedQizar/Java_app_3.0.git"
                )
            }
        }

        stage('Unit Test maven') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    mvnTest()
                }
            }
        }

        stage('Integration Test maven') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    mvnIntegrationTest()
                }
            }
        }

        stage('Static code analysis: Sonarqube') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    def SonarQubecredentialsId = 'sonarqube-api'
                    statiCodeAnalysis(SonarQubecredentialsId)
                }
            }
        }

        stage('Maven Build : maven') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    mvnBuild()
                }
            }
        }

        stage('Docker Image Build') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    dockerBuild("${params.ImageName}", "${params.ImageTag}", "${params.DockerHubUser}")
                }
            }
        }

 stage('Deploy to Tomcat') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    // Deploy WAR to Tomcat container running on port 8081
                    deployWarToTomcat("${params.WarFilePath}", "${params.TomcatContainerName}", "${params.TomcatUser}", "${params.TomcatPassword}")
                }
            }
        }



    }
}
def deployWarToTomcat(warFile, tomcatContainerName, tomcatUser, tomcatPassword) {
    // Ensure the WAR file is copied to the Tomcat container
    sh """
        WAR_FILE_NAME=\$(basename ${warFile})
        docker cp ${warFile} ${tomcatContainerName}:/usr/local/tomcat/webapps/
        docker exec ${tomcatContainerName} /bin/bash -c "curl -u ${tomcatUser}:${tomcatPassword} -T /usr/local/tomcat/webapps/\${WAR_FILE_NAME} ${env.TOMCAT_URL}?path=/\${WAR_FILE_NAME%.*}"
    """
}
