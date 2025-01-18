# === Build maven cache ===

FROM maven:3.9.9-eclipse-temurin-21 AS cache

# Ensure exercise dependencies are downloaded
WORKDIR /opt/exercise
COPY src/ src/
COPY pom.xml .
RUN mvn test dependency:go-offline -DexcludeReactor=false

# === Build runtime image ===

FROM maven:3.9.9-eclipse-temurin-21-alpine
WORKDIR /opt/test-runner

RUN apk update && \
        apk add --no-cache jq && \
        rm -rf /var/cache/apk/*

# Copy resources
COPY . .

# Copy cached dependencies
COPY --from=cache /root/.m2 /root/.m2

# Copy Maven pom.xml
COPY --from=cache /opt/exercise/pom.xml /root/pom.xml

ENTRYPOINT ["/opt/test-runner/bin/run.sh"]

