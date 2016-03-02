#!/bin/bash -ex

cd logsearch-boshrelease
scripts/generate_deployment_manifest aws "$STUB" > logsearch.yml
