
pipeline {
    agent {
        // Use a node with a specific label optimized for Docker builds
        label 'docker'
    }

    environment {
        registry = "590183706325.dkr.ecr.ap-south-1.amazonaws.com/docker-repo"
        imageName = "nginx-image"
        awsCredentialsId = "aws-ecr-credentials"
        region = "ap-south-1"
        namespace = "default"  // Set your Kubernetes namespace here
    }

    options {
        // Set a timeout to avoid hanging builds
        timeout(time: 30, unit: 'MINUTES')
        // Limit the number of concurrent builds
        throttleJobProperty(maxConcurrentPerNode: 2, maxConcurrentTotal: 4)
        // Use timestamps for better log readability
        timestamps()
        // Discard old builds to save disk space
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    stages {
        stage('Checkout') {
            steps {
                // Use shallow clone for faster checkout
                git branch: 'master', url: 'https://github.com/Bhargavi-lakamsani/helm-chart.git', shallow: true
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Use Docker layer caching to speed up build times
                    sh "docker build --cache-from ${registry}:latest -t ${imageName}:${BUILD_NUMBER} ."
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    // Efficient AWS credentials management with withAWS
                    withAWS(region: "${region}", credentials: "${awsCredentialsId}") {
                        sh """
                            $(aws ecr get-login-password --region ${region} | docker login --username AWS --password-stdin ${registry})
                            docker tag ${imageName}:${BUILD_NUMBER} ${registry}:${BUILD_NUMBER}
                            docker push ${registry}:${BUILD_NUMBER}
                        """
                    }
                }
            }
        }

        stage('Deploy with Helm') {
            steps {
                script {
                    // Helm deployment with set parameters
                    sh "helm upgrade --install nginx-release ./nginx-chart --namespace ${namespace} --set image.repository=${registry} --set image.tag=${BUILD_NUMBER}"
                }
            }
        }
    }

    post {
        always {
            // Clean up Docker images to free up space
            sh "docker rmi ${imageName}:${BUILD_NUMBER} || true"
            sh "docker rmi ${registry}:${BUILD_NUMBER} || true"
        }
        success {
            // Notify on successful build (e.g., Slack, email)
            echo 'Build and deployment successful!'
        }
        failure {
            // Notify on failure and collect logs
            echo 'Build or deployment failed!'
        }
    }
}
