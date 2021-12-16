#!/usr/bin/env groovy

pipeline {
    agent any
    options {
        // This is required if you want to clean before build
        skipDefaultCheckout(true)
    }
    environment {
        appName = sh (returnStdout: true, script: 'python3 setup.py --name').trim()
        Version = sh (returnStdout: true, script: 'python3 setup.py --version').trim()
    }
    stages{
        stage ('clean workspace') {
            steps {
                // clean workspace
                cleanWs()
            }
        }
        stage ('get info') {
            steps {
                checkout scm
                // get info
                echo 'Getting info of the app'
                echo "This app is $appName:$Version"
            }
        }

        stage ('test') {
            steps {
                echo 'Testing the code'
                
            }
        }
        
        // clear dangleing or stale images
        stage('Cleanup'){
            steps{
                sh '''
                docker rmi $(docker images -f 'dangling=true' -q) || true
                docker rmi $(docker images | sed 1,2d | awk '{print $3}') || true
                '''
            }

    }

        stage('build and push docker image') {
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

        stage('provision EKS') {
            environment {
                // pass aws credential as enviromental variables to terraform
                // varaible names have to be AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
                // Create a secret texts for AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY respectively. 
                // reference: https://www.jenkins.io/doc/book/pipeline/jenkinsfile/#for-other-credential-types
                AWS_ACCESS_KEY_ID = credentials('jenkins-aws-secret-key-id')
                AWS_SECRET_ACCESS_KEY = credentials('jenkins-aws-secret-access-key')
                TF_VAR_env_prefix = 'test'
            }
            steps {
                script {
                    dir('terraform') {
                        sh "terraform init"
                        sh "terraform apply --auto-approve"
                        EC2_PUBLIC_IP = sh(
                            script: "terraform output ec2_public_ip",
                            returnStdout: true
                        ).trim()
                    }
                }
            }
        }
        // stage('deploy on EKS') {
        //     steps {

        //     }
        // }

        // stage ('install Prometheus') {

        // }
    }
}
