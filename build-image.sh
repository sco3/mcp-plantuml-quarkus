./gradlew build \
    -Dquarkus.native.enabled=true \
    -Dquarkus.native.container-build=true \
    -Dquarkus.container-image.build=true \
    -Dquarkus.jib.base-native-image=registry.access.redhat.com/ubi8/ubi-minimal:8.10