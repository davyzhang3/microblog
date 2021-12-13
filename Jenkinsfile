#!/usr/bin/env groovy

pipeline {
    agent none

    stages{
        stage('Build image'){
            agent { dockerfile true }
            steps {
                sh 'flask --version'
            }
        }
    }
}
