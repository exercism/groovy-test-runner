# === Build maven cache ===

FROM maven:3.9-eclipse-temurin-26-alpine@sha256:4c85d516dd8c7e50d49a403d604e565e0dbb09a790186fe3245725d313ae7cb9 AS cache

# Ensure exercise dependencies are downloaded
WORKDIR /opt/exercise
COPY src/ src/
COPY pom.xml .
RUN mvn test dependency:go-offline -DexcludeReactor=false

# === Build runtime image ===

FROM maven:3.9-eclipse-temurin-26-alpine@sha256:4c85d516dd8c7e50d49a403d604e565e0dbb09a790186fe3245725d313ae7cb9
WORKDIR /opt/test-runner

RUN apk update && \
        apk add --no-cache --upgrade jq sed grep && \
        rm -rf /var/cache/apk/*

# Copy resources
COPY . .

# Copy cached dependencies
COPY --from=cache /root/.m2 /root/.m2

# Copy Maven pom.xml
COPY --from=cache /opt/exercise/pom.xml /root/pom.xml

ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
