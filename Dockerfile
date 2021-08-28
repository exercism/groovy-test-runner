FROM gradle:6.3.0-jdk11

RUN apt-get update && \
    apt-get install -y jq && \
    apt-get purge --auto-remove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/test-runner
# necessary because of https://github.com/keeganwitt/docker-gradle#reusing-the-gradle-cache
ENV GRADLE_USER_HOME /root/

COPY src/ src/
COPY build.gradle .
RUN gradle build

COPY . .

ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
