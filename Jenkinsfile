#!/usr/bin/env groovy

pipeline {
    agent any

    stages{
        stage ('get version number') {
            steps {
                echo 'Getting version of microblog'
                echo 'python setup.py --version'

                sh 'echo python setup.py --version > $WORKSPACE/env.Version'
            }
        }

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
