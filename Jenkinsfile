pipeline {
    agent any

    environment {
        TF_IN_AUTOMATION = 'true'
        TF_CLI_ARGS = '-no-color'
        AWS_REGION = 'us-east-1'
        SSH_CRED_ID = 'aws-deployer-ssh-key'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-cred1'
                ]]) {
                    bat 'terraform init'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-cred1'
                ]]) {
                    bat "terraform plan -var-file=%BRANCH_NAME%.tfvars"
                }
            }
        }

        stage('Approve Apply') {
            input {
                message "Apply Terraform changes for %BRANCH_NAME%?"
                ok "Apply"
            }
        }

        stage('Terraform Apply & Capture Outputs') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-cred1'
                ]]) {
                    script {
                        bat "terraform apply -auto-approve -var-file=%BRANCH_NAME%.tfvars"

                        env.INSTANCE_IP = bat(
                            script: "terraform output -raw instance_public_ip",
                            returnStdout: true
                        ).trim()

                        env.INSTANCE_ID = bat(
                            script: "terraform output -raw instance_id",
                            returnStdout: true
                        ).trim()

                        echo "EC2 IP: ${env.INSTANCE_IP}"
                        echo "EC2 ID: ${env.INSTANCE_ID}"

                        bat "echo ${env.INSTANCE_IP} > dynamic_inventory.ini"
                    }
                }
            }
        }

        stage('Wait for EC2 Health') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-cred1'
                ]]) {
                    bat """
                      aws ec2 wait instance-status-ok ^
                      --instance-ids ${env.INSTANCE_ID} ^
                      --region ${AWS_REGION}
                    """
                }
            }
        }

        stage('Approve Ansible') {
            input {
                message "Run Ansible on %BRANCH_NAME%?"
                ok "Run Ansible"
            }
        }

        stage('Ansible Configuration') {
            steps {
                ansiblePlaybook(
                    playbook: 'playbooks/grafana.yml',
                    inventory: 'dynamic_inventory.ini',
                    credentialsId: SSH_CRED_ID
                )
            }
        }

        stage('Approve Destroy') {
            input {
                message "Destroy infra for %BRANCH_NAME%?"
                ok "Destroy"
            }
        }

        stage('Terraform Destroy') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-cred1'
                ]]) {
                    bat "terraform destroy -auto-approve -var-file=%BRANCH_NAME%.tfvars"
                }
            }
        }
    }

    post {
        always {
            bat 'del dynamic_inventory.ini 2>NUL'
        }
        success {
            echo '✅ Pipeline completed successfully'
        }
        failure {
            echo '❌ Pipeline failed'
        }
    }
}
