#!/usr/bin/env groovy

pipeline {
    agent any
    environment {
        appName = sh (returnStdout: true, script: 'python3 setup.py --name').trim()
        Version = sh (returnStdout: true, script: 'python3 setup.py --version').trim()
        AWS_ACCESS_KEY_ID = credentials('jenkins-aws-secret-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('jenkins-aws-secret-access-key')
    }
    stages{
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
                        EKS_CLUSTER_ID = sh(
                            script: "terraform output eks-cluster-id",
                            returnStdout: true
                        ).trim()
                        echo "${EKS_CLUSTER_ID}"
                    }
                }
            }
        }
        // download AWS CLI, kubectl in Jenkins server before applying
        // https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
        stage('deploy on EKS') {
            steps {
                echo "update config file for kubernetes"
                sh "aws eks update-kubeconfig --name $EKS_CLUSTER_ID --region us-east-1"
                
                script {
                    dir('kubernetes') {
                        sh "kubectl apply -f myapp-mysql.yaml"
                        sh "kubectl apply -f myapp-microblog.yaml"

                        echo "waiting for my app to initialize"
                        sleep(time: 120, unit: "SECONDS")

                        EKS_IP = sh(
                            script: "kubectl get service/microblog-service --output jsonpath='{.status.loadBalancer.ingress[0].hostname}'",
                            returnStdout: true
                        ).trim()

                        EKS_IP_PORT = sh(
                            script: "kubectl get service/microblog-service --output jsonpath='{.spec.ports[0].port}'",
                            returnStdout: true
                        ).trim()
                        echo "The IP address of your web app is $EKS_IP:$EKS_IP_PORT"
                    }
                }
                

            }
        }
        // make sure you have helm installed on Jenkins server
        stage ('deploy Prometheus') {
            steps {
                sh ''' helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
                kubectl create namespace monitoring
                helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring
                '''
                sleep(time: 120, unit: "SECONDS")
                sh '''kubectl get all -n monitoring'''
            }
        }
    }
    post { 
        always { 
            cleanWs()
        }
    }
}
