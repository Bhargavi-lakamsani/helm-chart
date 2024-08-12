pipeline {
    agent any

    environment {
        registry = "590183706325.dkr.ecr.ap-south-1.amazonaws.com/docker-repo"
        imageName = "nginx-image"
        namespace = "dev"  // Target namespace
        awsCredentialsId = "aws-ecr-credentials"
        region = "ap-south-1"  // Set the AWS region
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/Bhargavi-lakamsani/helm-chart.git'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${imageName}:${BUILD_NUMBER} ."
                }
            }
        }
        
        stage('Push Docker Image') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: awsCredentialsId]]) {
                        sh "aws ecr get-login-password --region ${region} | docker login --username AWS --password-stdin ${registry}"
                        sh "docker tag ${imageName}:${BUILD_NUMBER} ${registry}:${BUILD_NUMBER}"
                        sh "docker push ${registry}:${BUILD_NUMBER}"
                    }
                }
            }
        }
        
        stage('Create Namespace') {
            steps {
                script {
                    sh "kubectl get namespace ${namespace} || kubectl create namespace ${namespace}"
                }
            }
        }
        
        stage('Deploy with Helm') {
            steps {
                script {
                    sh "helm upgrade --install nginx-release ./nginx-chart --namespace ${namespace} --set image.repository=${registry} --set image.tag=${BUILD_NUMBER}"
                }
            }
        }
    }
}
