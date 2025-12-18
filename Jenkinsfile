pipeline {
    agent any

    environment {
        TF_IN_AUTOMATION = 'true'
        TF_CLI_ARGS = '-no-color'
        AWS_DEFAULT_REGION = 'us-east-2'
        // Using credentials() helper is the most secure way for Windows
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
    }

    stages {
        stage('Terraform Init') {
            steps {
                // '@' suppresses the command output to prevent shell mangling of characters
                bat '@echo off & terraform init'
            }
        }

        stage('Terraform Plan') {
            steps {
                bat "@echo off & terraform plan -var-file=%BRANCH_NAME%.tfvars"
            }
        }

        stage('Approve Apply') {
            steps {
                input(message: "Do you want to apply this plan?", ok: "Apply")
            }
        }

        stage('Terraform Apply') {
            steps {
                bat "@echo off & terraform apply -auto-approve -var-file=%BRANCH_NAME%.tfvars"

                script {
                    // Using powershell can be more reliable for capturing raw strings on Windows
                    env.INSTANCE_IP = powershell(returnStdout: true, script: 'terraform output -raw instance_public_ip').trim()
                    env.INSTANCE_ID = powershell(returnStdout: true, script: 'terraform output -raw instance_id').trim()
                }

                echo "Instance IP: ${env.INSTANCE_IP}"
                echo "Instance ID: ${env.INSTANCE_ID}"
                writeFile file: 'dynamic_inventory.ini', text: env.INSTANCE_IP
            }
        }

        stage('Wait for Instance Health') {
            steps {
                bat "@echo off & aws ec2 wait instance-status-ok --instance-ids %INSTANCE_ID% --region %AWS_DEFAULT_REGION%"
            }
        }

        stage('Approve Ansible') {
            steps {
                input(message: "Run Ansible configuration?", ok: "Run")
            }
        }

        stage('Ansible Configuration') {
            steps {
                // Ensure the Ansible plugin is installed in Jenkins
                ansiblePlaybook(
                    playbook: 'playbooks/grafana.yml',
                    inventory: 'dynamic_inventory.ini'
                )
            }
        }

        stage('Approve Destroy') {
            steps {
                input(message: "Destroy infrastructure?", ok: "Destroy")
            }
        }

        stage('Terraform Destroy') {
            steps {
                bat "@echo off & terraform destroy -auto-approve -var-file=%BRANCH_NAME%.tfvars"
            }
        }
    }

    post {
        always {
            bat 'if exist dynamic_inventory.ini del dynamic_inventory.ini'
        }
    }
}