# === Build maven cache ===

FROM maven:3.8.3-jdk-11 AS cache

# Ensure exercise dependencies are downloaded
WORKDIR /opt/exercise
COPY src/ src/
COPY pom.xml .
RUN mvn test dependency:go-offline -DexcludeReactor=false

# === Build runtime image ===

FROM maven:3.8.3-jdk-11-slim
WORKDIR /opt/test-runner

RUN apt-get update && \
    apt-get install -y jq && \
    apt-get purge --auto-remove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy resources
COPY . .

# Copy cached dependencies
COPY --from=cache /root/.m2 /root/.m2

# Copy Maven pom.xml
COPY --from=cache /opt/exercise/pom.xml /root/pom.xml

ENTRYPOINT ["/opt/test-runner/bin/run.sh"]

