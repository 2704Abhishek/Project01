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
                echo "Build step (not required for static web apps)"
            }
        }

       stage('Deploy') {
    steps {
        echo "Deploying Web App..."
        bat '''
        if not exist deploy mkdir deploy

        for /D %%G in (*) do (
            if /I not "%%G"=="deploy" xcopy "%%G" "deploy\\%%G" /E /I /Y
        )

        for %%F in (*) do (
            if not "%%F"=="deploy" xcopy "%%F" "deploy\\" /Y
        )
        '''
    }
}


    post {
        success {
            echo "✅ Pipeline executed successfully"
        }
        failure {
            echo "❌ Pipeline failed"
        }
    }
}

