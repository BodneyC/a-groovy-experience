#!/usr/bin/env bash

# Just for testing
_jenkinsfile="${1:-$(
  dirname "${BASH_SOURCE[0]}"
)/example-pipelines/invalid-agent.groovy}"

JENKINS_URL="localhost:8080"

# Why does the crumb thing never work...?
# JENKINS_CRUMB="$(
#   curl -q \
#     "$JENKINS_URL/crumbIssuer/api/xml?$(
#     )xpath=concat(//crumbRequestField,\":\",//crumb)"
# )"

curl -q -X POST \
  -F "jenkinsfile=<$_jenkinsfile" \
  "$JENKINS_URL/pipeline-model-converter/validate"
