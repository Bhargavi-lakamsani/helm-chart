pipeline {
    agent any

    environment {
        registry = "590183706325.dkr.ecr.ap-south-1.amazonaws.com/docker-repo"
        imageName = "nginx-image"
        namespace = "dev"  // Target namespace
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${registry}/${imageName}:${BUILD_NUMBER} ."
                }
            }
        }
        
        stage('Push Docker Image') {
            steps {
                script {
                    sh "aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin ${registry}"
                    sh "docker push ${registry}/${imageName}:${BUILD_NUMBER}"
                }
            }
        }
        
        stage('Deploy with Helm') {
            steps {
                script {
                    sh "helm upgrade --install nginx-release ./nginx-chart --namespace ${namespace} --set image.repository=${registry}/${imageName} --set image.tag=${BUILD_NUMBER}"
                }
            }
        }
    }
}

