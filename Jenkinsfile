#!/usr/bin/env groovy

pipeline {
    agent any
    environment { 
        appName = sh (returnStdout: true, script: 'python3 setup.py --name').trim()
        Version = sh (returnStdout: true, script: 'python3 setup.py --version').trim()
    }
    stages{
        stage ('get info') {
            steps {
                echo 'Getting version of microblog'
                echo "This app is $appName:$Version"
            }
        }

        stage('build image') {
            steps {
                script {
                    echo "building the docker image..."
                    withCredentials([usernamePassword(credentialsId: 'Dawei-Dockerhub-Credential', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                        sh 'docker build -t $USER/$appName:$Version .'
                        sh 'echo $PASS | docker login -u $USER --password-stdin '
                        sh 'docker push $USER/$appName:$Version'
                    }
                }
            }
        }
    }
}
