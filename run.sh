#!/usr/bin/env -S bash

set -xueo pipefail

jar=$(find $(dirname $(readlink -f $0))/build/ -name code-with-quarkus-*-runner.jar | grep -v /gen/ | head -n1)


java -jar "$jar" --quiet 
