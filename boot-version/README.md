# MCP PlantUML - Spring Boot 3 Version

This project uses Spring Boot 3, the Supersonic Subatomic Java Framework.

If you want to learn more about Spring Boot, please visit its website: <https://spring.io/projects/spring-boot>.

## Running the application in dev mode

You can run your application in dev mode that enables live coding using:

```shell script
./gradlew bootRun
```

## Packaging and running the application

The application can be packaged using:

```shell script
./gradlew build
```

It produces the jar file in the `build/libs/` directory.

The application is now runnable using `java -jar build/libs/*.jar`.

## Creating a Docker image

You can create a Docker image using:

```shell script
./build-docker.sh
```

Or manually:

```shell script
./gradlew build
docker build -t mcp-plantuml-boot:latest .
```

## Related Guides

- MCP Server Spring SDK ([guide](https://github.com/modelcontextprotocol/java-sdk)): This extension enables developers to implement the MCP server features easily.
- Spring Boot ([guide](https://spring.io/guides)): The Spring Boot framework.
