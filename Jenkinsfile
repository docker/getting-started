pipeline {
    options {
        timeout(time: 1, unit: 'HOURS')
    }
    agent {
        label 'ec2'
    }
    stages {
        stage('test') {
            when {
                not { branch 'master' }
            }

            steps {
                sh "docker build -t docker/getting-started ."
            }
        }
        stage('build and push') {
            when {
                branch 'master'
            }

            steps {
                sh "docker build -t docker/getting-started ."
                withDockerRegistry([url: "", credentialsId: "dockerbuildbot-index.docker.io"]) {
                    sh("docker push docker/getting-started")
                }
            }
        }
    }
}
