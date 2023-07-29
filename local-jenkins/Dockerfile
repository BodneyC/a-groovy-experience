FROM jenkins/jenkins:2.416-jdk11

ENV JAVA_OPTS "-Djenkins.install.runSetupWizard=false \
-Dhudson.security.csrf.GlobalCrumbIssuerConfiguration.DISABLE_CSRF_PROTECTION=true"

ADD ./config.xml "$JENKINS_HOME/config.xml"

RUN jenkins-plugin-cli --plugins "pipeline-model-definition job-dsl"
