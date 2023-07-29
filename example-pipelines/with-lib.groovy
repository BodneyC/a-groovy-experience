@Library('my-shared-library') _
pipeline {
    agent any
    stages {
        stage('Initialize') {
            steps {
                echo 'Placeholder.'
            }
        }
    }
}
