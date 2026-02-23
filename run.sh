#!/usr/bin/env -S bash

set -xueo pipefail

jar=$(find $(dirname $(readlink -f $0)) -name math-tool-\*-runner.jar | grep -v /gen/ )


java -jar "$jar" --quiet 
