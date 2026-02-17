#!/bin/bash
# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


set -e

# Configuration via environment variables (with defaults for backward compatibility)
GITHUB_ORG="${GITHUB_ORG:-navikt}"
GITHUB_APP_ID="${GITHUB_APP_ID:-2878174}"
GITHUB_APP_INSTALLATION_ID="${GITHUB_APP_INSTALLATION_ID:-110638335}"
GITHUB_APP_PRIVATE_KEY_PATH="${GITHUB_APP_PRIVATE_KEY_PATH}"
RUNNER_LABELS="${RUNNER_LABELS:-foo,bar}"
RUNNER_GROUP="${RUNNER_GROUP:-Default}"

# Validate that the private key exists
if [ ! -f "${GITHUB_APP_PRIVATE_KEY_PATH}" ]; then
  echo "ERROR: Private key not found at ${GITHUB_APP_PRIVATE_KEY_PATH}"
  echo "Mount your key.pem file, e.g.: docker run -v /path/to/key.pem:/home/runner/key.pem ..."
  exit 1
fi

# Prepare internal variables.
GH_TOKEN=$(./create_jwt_token.sh "${GITHUB_APP_ID}" "${GITHUB_APP_PRIVATE_KEY_PATH}" "${GITHUB_ORG}" "${GITHUB_APP_INSTALLATION_ID}")

echo "token: ${GH_TOKEN}"

RUNNER_PREFIX="union-ci-runner"
RUNNER_SUFFIX=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 5 | head -n 1)
RUNNER_NAME="${RUNNER_PREFIX}-${RUNNER_SUFFIX}"

echo "Runner:"
echo "$RUNNER_SUFFIX"
echo "$RUNNER_NAME"

# [START cloudrun_github_worker_pool_start]
# Configure the current runner instance with URL, token and name.
# mkdir -p /home/runner/actions-runner && cd /home/runner/actions-runner
./config.sh --unattended --url "https://github.com/${GITHUB_ORG}" --token "${GH_TOKEN}" --name "${RUNNER_NAME}" --labels "${RUNNER_LABELS}" --runnergroup "${RUNNER_GROUP}"

# Function to cleanup and remove runner from Github.
cleanup() {
   echo "Removing runner..."
   ./config.sh remove --unattended --token "${GH_TOKEN}"
}

# Trap signals.
trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

# Run the runner.
./run.sh & wait $!

# [END cloudrun_github_worker_pool_start]
