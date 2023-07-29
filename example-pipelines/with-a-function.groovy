pipeline {
    agent any
    stages {
        stage('Initialize') {
            steps {
                runFunction()
            }
        }
    }
}

String runFunction(String a) {
    return a
}
