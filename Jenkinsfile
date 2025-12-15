pipeline {
    agent any

    stages {

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

