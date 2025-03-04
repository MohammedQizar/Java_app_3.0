@Library('my-shared-library') _

pipeline {
    agent any
    // agent { label 'Demo' }

    parameters {
        choice(name: 'action', choices: ['create', 'delete'], description: 'Choose create/Destroy')
        string(name: 'ImageName', description: "name of the docker build", defaultValue: 'javapp')
        string(name: 'ImageTag', description: "tag of the docker build", defaultValue: 'v1')
        string(name: 'DockerHubUser', description: "name of the Application", defaultValue: 'mohammedqizar')
        string(name: 'JarFilePath', description: "Path to the JAR file", defaultValue: 'target/kubernetes-configmap-reload-0.0.1-SNAPSHOT.jar')
        string(name: 'TomcatContainerName', description: "Name of the Tomcat Docker container", defaultValue: 'tomcat-container')
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
            // Assuming Tomcat is running in Docker container and WAR file is built
            def warFile = "${params.WarFilePath}"
            def tomcatContainerName = "${params.TomcatContainerName}"

            // Use Jenkins credentials to securely inject the private key
            withCredentials([sshUserPrivateKey(credentialsId: 'my-ec2-ssh-key', keyFileVariable: 'SSH_PRIVATE_KEY')]) {
                // Now SSH_PRIVATE_KEY is available and can be used in the script
                sh """
                    ssh -i ${SSH_PRIVATE_KEY} ec2-user@52.53.248.184 'docker cp ${warFile} ${tomcatContainerName}:/usr/local/tomcat/webapps/'
                """
                
                // Restart Tomcat to deploy the WAR using SSH
                sh """
                    ssh -i ${SSH_PRIVATE_KEY} ec2-user@52.53.248.184 'docker exec ${tomcatContainerName} /bin/bash -c "catalina.sh stop && catalina.sh start"'
                """
            }
        }
    }
}




    }
}
