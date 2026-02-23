.PHONY: build build-image compile-native inspector run run-dev help all

all: help

help:
	@echo "Available targets:"
	@echo "  build          - Build the project with container image"
	@echo "  build-image    - Build native image with container"
	@echo "  compile-native - Compile native binary"
	@echo "  inspector      - Run MCP inspector"
	@echo "  run            - Run the built jar"
	@echo "  run-dev        - Run in development mode"
	@echo "  help           - Show this help message"

build:
	./gradlew build -Dquarkus.container-image.build=true

build-image:
	./gradlew build \
		-Dquarkus.native.enabled=true \
		-Dquarkus.native.container-build=true \
		-Dquarkus.container-image.build=true \
		-Dquarkus.jib.base-native-image=registry.access.redhat.com/ubi8/ubi-minimal:8.10

compile-native:
	quarkus build --native

inspector:
	npx @modelcontextprotocol/inspector

run:
	jar=$$(find ./build/ -name 'code-with-quarkus-*-runner.jar' | grep -v /gen/ | head -n1) && \
	java -jar "$$jar" --quiet

run-dev:
	./gradlew quarkusDev
