Pipeline Script:
pipeline {
    agent any

    environment {
        IMAGE_NAME = "student-app"
        VERSION = "1.2"
    }

    stages {

        stage('Checkout') {
            steps {
                git 'https://github.com/vishnutg0509/getting-started.git'
            }
        }

        stage('Build') {
            steps {
                sh 'echo Building Application'
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                docker build -t ${IMAGE_NAME}:${VERSION} .
                '''
            }
        }

        stage('Docker Test') {
            steps {
                sh '''
                docker run -d --name temp-test -p 4000:80 ${IMAGE_NAME}:${VERSION}
                sleep 15
                curl http://localhost:4000
                docker rm -f temp-test
                '''
            }
        }

        stage('Deploy DEV') {
            steps {
                sh '''
                docker rm -f student-dev || true

                docker run -d \
                --name student-dev \
                -p 3001:80 \
                ${IMAGE_NAME}:${VERSION}
                '''
            }
        }

        stage('Smoke Test') {
            steps {
                sh '''
                curl http://13.236.137.237:3001
                '''
            }
        }

        stage('Deploy QA') {
            steps {
                sh '''
                docker rm -f student-qa || true

                docker run -d \
                --name student-qa \
                -p 3002:80 \
                ${IMAGE_NAME}:${VERSION}
                '''
            }
        }

        stage('QA Test') {
            steps {
                sh '''
                curl http://13.236.137.237:3002
                '''
            }
        }

        stage('Manual Approval') {
            steps {
                input message: 'Deploy to Production?'
            }
        }

        stage('Deploy PROD') {
            steps {
                sh '''
                docker rm -f student-prod || true

                docker run -d \
                --name student-prod \
                -p 3003:80 \
                ${IMAGE_NAME}:${VERSION}
                '''
            }
        }

        stage('Production Health Check') {
            steps {
                sh '''
                curl http://13.236.137.237:3003
                '''
            }
        }
    }
}
