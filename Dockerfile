# STAGE 1: Build the App (using GraalVM 25)
FROM ghcr.io/graalvm/graalvm-community:25 AS build
WORKDIR /app

# Copy Gradle wrapper and configuration files
COPY gradlew settings.gradle build.gradle gradle.properties ./
COPY gradle/ gradle/
RUN chmod +x ./gradlew

# Copy source code
COPY src/ src/

# Build the project
RUN ./gradlew clean build -x test

# STAGE 2: Create the custom JRE
# We now only scan the single fat JAR
RUN JAR_FILE="build/mcp-server-plantuml-1.0.0-SNAPSHOT-runner.jar" && \
    /opt/graalvm-community-java25/bin/jdeps \
    --ignore-missing-deps \
    --print-module-deps \
    --multi-release 25 \
    --class-path "$JAR_FILE" \
    "$JAR_FILE" > /modules.txt

RUN /opt/graalvm-community-java25/bin/jlink \
    --add-modules $(cat /modules.txt) \
    --strip-debug \
    --no-man-pages \
    --no-header-files \
    --compress=2 \
    --output /javaruntime

# STAGE 2b: Install zlib (using ubi9-minimal with microdnf)
FROM registry.access.redhat.com/ubi9/ubi-minimal:latest AS libs
RUN microdnf install zlib harfbuzz freetype bzip2-libs libpng harfbuzz brotli libbrotli glib2 graphite2 -y && microdnf clean all

# STAGE 3: Runner
FROM registry.access.redhat.com/ubi9/ubi-micro:latest
WORKDIR /app

# Copy zlib libraries from libs stage

COPY --from=libs /usr/lib64/libz.so* /usr/lib64/
COPY --from=libs /usr/lib64/libfreetype.so* /usr/lib64/
COPY --from=libs /usr/lib64/libbz2.so* /usr/lib64/
COPY --from=libs /usr/lib64/libpng16.so* /usr/lib64/
COPY --from=libs /usr/lib64/libharfbuzz.so* /usr/lib64/
COPY --from=libs /usr/lib64/libbrotli*.so* /usr/lib64/
COPY --from=libs /usr/lib64/libglib* /usr/lib64/
COPY --from=libs /usr/lib64/libgraphite2.so* /usr/lib64/


# Copy the custom runtime
COPY --from=build /javaruntime /opt/java-runtime

# Copy the fat JAR
COPY --from=build /app/build/mcp-server-plantuml-1.0.0-SNAPSHOT-runner.jar /app/app.jar

# Set environment
ENV JAVA_HOME=/opt/java-runtime
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Start the application
ENTRYPOINT ["/opt/java-runtime/bin/java", "-jar", "/app/app.jar"]