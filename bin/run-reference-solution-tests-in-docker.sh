#!/usr/bin/env bash

set -e

# Synopsis:
# Test the test runner Docker image by running it against all reference solutions from the Groovy repository.
# It is recommended to run this script when upgrading Groovy exercises or Groovy test runner dependencies.

# Output:
# Fails is

# Example:
# ./bin/run-reference-solution-tests-in-docker.sh

# Build the Docker image
docker build --rm -t exercism/groovy-test-runner .
export BUILD_IMAGE=false

# Assumes exercism/groovy repository is checked out next to the exercism/groovy-test-runner repository.
# If the repository is checked out elsewhere, provide the path as the first argument.
groovy_repo_path=$(realpath "${1:-${PWD}/../groovy}")
repo_root=$(git rev-parse --show-toplevel)
rm -r "${repo_root}/tmp" || true

# Iterate over all exercises directories
for exercise_dir in "${groovy_repo_path}"/exercises/practice/*; do
  exercise_slug=$(basename "${exercise_dir}")
  exercise_tmp_dir="${repo_root}/tmp/${exercise_slug}"
  mkdir -p "${exercise_tmp_dir}"
  cp -R "${exercise_dir}/" "${exercise_tmp_dir}"
  cp -R "${exercise_dir}/.meta/src/reference/" "${exercise_tmp_dir}/src/main"
  eval "${repo_root}/bin/run-in-docker.sh" "${exercise_slug}" "${exercise_tmp_dir}" "${exercise_tmp_dir}/output"
  results_json="${exercise_tmp_dir}/output/results.json"
  status=$(jq -r ".status" "${results_json}")
  if [[ "${status}" != "pass" ]]; then
    echo "💥 Test failed for ${exercise_slug}, check the output in ${results_json}"
    exit 1
  fi
done

echo "✅ All tests passed"
