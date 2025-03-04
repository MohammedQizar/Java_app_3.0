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
            def warFile = "${params.JarFilePath}"
            def tomcatContainerName = "${params.TomcatContainerName}"

            // Step 1: Copy the WAR file into Tomcat's webapps directory using SSH
            sh """
                ssh -i /path/to/private-key ec2-user@19.33.23.123 'docker cp ${warFile} ${tomcatContainerName}:/usr/local/tomcat/webapps/'
            """
            
            // Step 2: Restart Tomcat to deploy the WAR using SSH
            sh """
                ssh -i /path/to/private-key ec2-user@19.33.23.123 'docker exec ${tomcatContainerName} /bin/bash -c "catalina.sh stop && catalina.sh start"'
            """
        }
    }
}



    }
}
