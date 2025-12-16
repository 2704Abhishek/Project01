pipeline {
    agent any

    stages{
        steps("terraform init") {
            sh 'terraform init'
        }
    }

    stages {
        steps("terraform plan") {
            sh 'terraform plan'
        }
    }

    stages {
        steps("terraform apply -auto-approve") {
            sh 'terraform apply -auto-approve'
        }
    }

    

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/2704Abhishek/Project01.git'
            }
        }

        stage('Build') {
            steps {
                echo 'Build step (not required for static web apps)'
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying Web App...'
                bat '''
                echo Deployment successful on Windows
                dir
                '''
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline executed successfully'
        }
        failure {
            echo '❌ Pipeline failed'
        }
    }
}

// webhook auto-build final test
