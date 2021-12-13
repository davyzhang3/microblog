#!/usr/bin/env groovy

pipeline {
    agent any

    stages{
        stage('build image') {
            steps {
                script {
                    echo "building the docker image..."
                    withCredentials([usernamePassword(credentialsId: 'Dawei-Dockerhub-Credential', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                        sh "docker build -t $USER/microblog:0.0.1 ."
                        sh "echo $PASS | docker login -u $USER --password-stdin "
                        sh "docker push $USER/microblog:0.0.1"
                    }
                }
            }
        }
    }
}
