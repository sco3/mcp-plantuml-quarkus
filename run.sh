#!/usr/bin/env -S bash

set -xueo pipefail

jar=$(find $(dirname $(readlink -f $0)) -name mcp-server-\*-runner.jar | grep -v /gen/ )


~/prg/java-25/bin/java -jar "$jar" --quiet 
