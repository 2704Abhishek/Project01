pipeline {
    agent any

    environment {
        TF_IN_AUTOMATION = 'true'
        TF_CLI_ARGS = '-no-color'
        AWS_DEFAULT_REGION = 'us-east-2'
    }

    stages {
        stage('Terraform Init') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    bat 'terraform init'
                    bat "type %BRANCH_NAME%.tfvars"
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    bat "terraform plan -var-file=%BRANCH_NAME%.tfvars"
                }
            }
        }

        stage('Approve Apply') {
            steps {
                // FIXED: Changed curly braces to parentheses
                input(message: "Do you want to apply this plan?", ok: "Apply")
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    bat "terraform apply -auto-approve -var-file=%BRANCH_NAME%.tfvars"

                    script {
                        // Capture stdout from batch
                        env.INSTANCE_IP = bat(
                            script: 'terraform output -raw instance_public_ip',
                            returnStdout: true
                        ).trim().split('\n').last() // Added split/last to handle potential command echo in output

                        env.INSTANCE_ID = bat(
                            script: 'terraform output -raw instance_id',
                            returnStdout: true
                        ).trim().split('\n').last()
                    }

                    echo "Instance IP: ${env.INSTANCE_IP}"
                    echo "Instance ID: ${env.INSTANCE_ID}"

                    writeFile file: 'dynamic_inventory.ini', text: env.INSTANCE_IP
                }
            }
        }

        stage('Wait for Instance Health') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    bat "aws ec2 wait instance-status-ok --instance-ids %INSTANCE_ID% --region %AWS_DEFAULT_REGION%"
                }
            }
        }

        stage('Approve Ansible') {
            steps {
                // FIXED: Changed curly braces to parentheses
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
                // FIXED: Changed curly braces to parentheses
                input(message: "Destroy infrastructure?", ok: "Destroy")
            }
        }

        stage('Terraform Destroy') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    bat "terraform destroy -auto-approve -var-file=%BRANCH_NAME%.tfvars"
                }
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
            echo 'Pipeline failed ❌ — manual cleanup may be required'
        }
    }
}