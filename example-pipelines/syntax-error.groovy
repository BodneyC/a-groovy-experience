pipeline {
    stages { // missing brace (may be present for pre-commit)
        stage('Initialize') {
            steps {
                echo 'Placeholder.'
            }
        }
    }
}
