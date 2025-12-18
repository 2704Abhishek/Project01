pipeline {
    agent any

    environment {
        TF_IN_AUTOMATION = 'true'
        TF_CLI_ARGS = '-no-color'
        AWS_DEFAULT_REGION = 'us-east-2'
        // FIX: Inject credentials globally so Terraform and AWS CLI see them automatically
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
    }

    stages {
        stage('Terraform Init') {
            steps {
                // No need for withCredentials here anymore
                bat 'terraform init'
                // Use "if exist" to prevent failure if file is missing
                bat 'if exist %BRANCH_NAME%.tfvars type %BRANCH_NAME%.tfvars'
            }
        }

        stage('Terraform Plan') {
            steps {
                bat "terraform plan -var-file=%BRANCH_NAME%.tfvars"
            }
        }

        stage('Approve Apply') {
            steps {
                input(message: "Do you want to apply this plan?", ok: "Apply")
            }
        }

        stage('Terraform Apply') {
            steps {
                bat "terraform apply -auto-approve -var-file=%BRANCH_NAME%.tfvars"

                script {
                    // Optimized output capture for Windows
                    def ipOut = bat(script: 'terraform output -raw instance_public_ip', returnStdout: true).trim()
                    env.INSTANCE_IP = ipOut.split('\r?\n').last()

                    def idOut = bat(script: 'terraform output -raw instance_id', returnStdout: true).trim()
                    env.INSTANCE_ID = idOut.split('\r?\n').last()
                }

                echo "Instance IP: ${env.INSTANCE_IP}"
                echo "Instance ID: ${env.INSTANCE_ID}"
                writeFile file: 'dynamic_inventory.ini', text: env.INSTANCE_IP
            }
        }

        stage('Wait for Instance Health') {
            steps {
                // AWS CLI will now automatically find the env variables
                bat "aws ec2 wait instance-status-ok --instance-ids %INSTANCE_ID% --region %AWS_DEFAULT_REGION%"
            }
        }

        stage('Approve Ansible') {
            steps {
                input(message: "Run Ansible configuration?", ok: "Run")
            }
        }

        stage('Ansible Configuration') {
            steps {
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
                bat "terraform destroy -auto-approve -var-file=%BRANCH_NAME%.tfvars"
            }
        }
    }

    post {
        always {
            echo 'Cleaning up workspace'
            bat 'if exist dynamic_inventory.ini del dynamic_inventory.ini'
        }
        success {
            echo 'Pipeline completed successfully ✅'
        }
        failure {
            echo 'Pipeline failed ❌'
        }
    }
}