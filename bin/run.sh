#!/usr/bin/env bash

# Synopsis:
# Run the test runner on a solution.

# Arguments:
# $1: exercise slug
# $2: absolute path to solution folder
# $3: absolute path to output directory

# Output:
# Writes the test results to a results.json file in the passed-in output directory.
# The test results are formatted according to the specifications at https://github.com/exercism/docs/blob/main/building/tooling/test-runners/interface.md

# Example:
# ./bin/run.sh two-fer /absolute/path/to/two-fer/solution/folder/ /absolute/path/to/output/directory/

# If any required arguments is missing, print the usage and exit
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    echo "usage: ./bin/run.sh exercise-slug /absolute/path/to/two-fer/solution/folder/ /absolute/path/to/output/directory/"
    exit 1
fi

slug="$1"
input_dir="${2%/}"
output_dir="${3%/}"
exercise=$(echo "${slug}" | sed -r 's/(^|-)([a-z])/\U\2/g')
tests_file="${input_dir}/src/test/groovy/${exercise}Spec.groovy"
tests_file_original="${tests_file}.original"
results_file="${output_dir}/results.json"

# Create the output directory if it doesn't exist
mkdir -p "${output_dir}"

# Run this once to not show the welcome message
gradle --version > /dev/null

echo "${slug}: testing..."

cp "${tests_file}" "${tests_file_original}"

# TODO: figure out a nicer way to un-ignore the tests
sed -i -E 's/@Ignore//' "${tests_file}"

# TODO: figure out a nicer way to order the tests
sed -i -E "s/^class/@Stepwise\nclass/" "${tests_file}"

pushd "${input_dir}" > /dev/null

# Run the tests for the provided implementation file and redirect stdout and
# stderr to capture it
test_output=$(gradle --offline --console=plain test 2>&1)
exit_code=$?

popd > /dev/null

# Restore the original file
mv -f "${tests_file_original}" "${tests_file}"

# Write the results.json file based on the exit code of the command that was
# just executed that tested the implementation file
if [ $exit_code -eq 0 ]; then
    jq -n '{version: 1, status: "pass"}' > ${results_file}
else
    # Sanitize the output
    sanitized_output=$(printf "${test_output}" | \
        sed -E \
          -e 's/^Starting a Gradle Daemon.*$//' \
          -e 's/See the report.*//' \
          -e '/^> Task/d' | \
        sed -n '/Try:/q;p' | \
        sed -e '/./,$!d' -e :a -e '/^\n*$/{$d;N;ba' -e '}' | \
        sed -e '/^$/N;/^\n$/D')

    # Manually add colors to the output to help scanning the output for errors
    colorized_test_output=$(echo "${sanitized_output}" | \
        GREP_COLOR='01;31' grep --color=always -E -e '(^FAIL.*$|.*FAILED$)|$' | \
        GREP_COLOR='01;32' grep --color=always -E -e '.*PASSED$|$')

    jq -n --arg output "${colorized_test_output}" '{version: 1, status: "fail", message: $output}' > ${results_file}
fi

echo "${slug}: done"
