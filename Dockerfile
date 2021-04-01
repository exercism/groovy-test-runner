FROM gradle:6.3.0-jdk11

RUN apt-get update && \
    apt-get install -y jq && \
    apt-get purge --auto-remove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/test-runner

COPY build.gradle .
RUN gradle clean build

COPY . .

ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
