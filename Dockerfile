FROM ghcr.io/graalvm/graalvm-community:21 AS build
WORKDIR /app

# Copy Gradle wrapper and configuration files
COPY --chmod 755 gradlew settings.gradle build.gradle gradle.properties ./
COPY gradle/ gradle/

# Copy source code
COPY src/ src/

# Build the project
RUN ./gradlew clean build -x test

RUN $JAVA_HOME/bin/jlink \
    --add-modules java.base,java.desktop,java.xml,java.sql,java.naming,java.management,java.prefs,java.scripting,jdk.compiler,jdk.unsupported,jdk.crypto.ec,jdk.charsets \
    --strip-debug \
    --no-man-pages \
    --no-header-files \
    --compress=2 \
    --output /javaruntime


# Runner

FROM registry.access.redhat.com/ubi9/ubi-minimal:latest

RUN  microdnf install fontconfig dejavu-sans-fonts  zlib harfbuzz freetype bzip2-libs libpng harfbuzz brotli libbrotli glib2 graphite2 -y && microdnf clean all


WORKDIR /app

# Copy the custom runtime
COPY --from=build /javaruntime /opt/java-runtime

# Copy the fat JAR
COPY --from=build /app/build/mcp-server-plantuml-1.0.0-SNAPSHOT-runner.jar /app/app.jar

# Set environment
ENV JAVA_HOME=/opt/java-runtime
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Start the application
ENTRYPOINT ["/opt/java-runtime/bin/java", "-jar", "/app/app.jar"]