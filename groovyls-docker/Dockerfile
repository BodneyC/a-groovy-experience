FROM registry.access.redhat.com/ubi8/openjdk-17:1.16-2

USER 0

RUN microdnf install git

# wget -O gradle-8.3-rc-2-bin.zip https://services.gradle.org/distributions/gradle-8.3-rc-2-bin.zip
# sha256sum --check --status <<< "222818637ce0a4cb82e322bf847ea49ac319aecdb363d81acabd9e81315d08f6 gradle-8.3-rc-2-bin.zip"
# unzip gradle-8.3-rc-2-bin.zip
ADD ./gradle-8.3-rc-2/ /opt/gradle
RUN echo 'export GRADLE_HOME="/opt/gradle"' >> /etc/profile.d/gradle.sh
RUN echo 'export PATH="$GRADLE_HOME/bin:$PATH"' >> /etc/profile.d/gradle.sh

RUN cd /opt && git clone https://github.com/groovylanguageserver/groovy-language-server.git
RUN cd /opt/groovy-language-server && ./gradlew build

WORKDIR /opt/groovy-language-server

USER 185

ENTRYPOINT ["java", "-jar", "./build/libs/groovy-language-server-all.jar"]
