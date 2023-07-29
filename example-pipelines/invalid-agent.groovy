pipeline {
    agent // missing block
    stages {
        stage('Initialize') {
            steps {
                echo 'Placeholder.'
            }
        }
    }
}
