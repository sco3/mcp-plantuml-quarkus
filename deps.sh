
rm -rf build/custom-jre

jlink \
  --add-modules $( \
      jdeps --print-module-deps \
      --ignore-missing-deps \
      --multi-release 25 \
      --recursive \
      build/mcp-server-plantuml-1.0.0-SNAPSHOT-runner.jar \
  ) \
  --output build/custom-jre \
  --strip-debug \
  --no-man-pages \
  --no-header-files \
  --compress=2

