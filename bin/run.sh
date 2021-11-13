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

echo "${slug}: testing..."

cp "${tests_file}" "${tests_file_original}"

# TODO: figure out a nicer way to un-ignore the tests
sed -i -E 's/@Ignore//' "${tests_file}"

# TODO: figure out a nicer way to order the tests
sed -i -E "s/^class/@Stepwise\nclass/" "${tests_file}"

pushd "${input_dir}" > /dev/null

cp /root/pom.xml .

# jansi tmp directory needs to be a RWX folder
mkdir -p /solution/jansi-tmp
# Tuning those parametes can speed up things
export  JAVA_TOOL_OPTIONS="-Djansi.tmpdir=/solution/jansi-tmp -Xss128m -Xms256m -Xmx2G -XX:+UseG1GC"

# Remove maven cache if it exists
rm -rf target
# Run the tests for the provided implementation file and redirect stdout and
# stderr to capture it
test_output=$(mvn --offline --legacy-local-repository --batch-mode --non-recursive --quiet test 2>&1)
exit_code=$?

rm -f pom.xml

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
          -e '/Picked up JAVA_TOOL_OPTIONS*/d' \
          -e '/\[ERROR\] Picked up JAVA_TOOL_OPTIONS*/d' \
          -e '/\[ERROR\] Please refer to*/d' \
          -e '/\[ERROR\] To see the full stack trace*/d' \
          -e '/\[ERROR\] -> \[Help 1\]*/d' \
          -e '/\[ERROR\] $/d' \
          -e '/\[ERROR\] For more information about the errors*/d' \
          -e '/\[ERROR\] Re-run Maven using the -X*/d' \
          -e '/\[ERROR\] Failed to execute goal*/d' \
          -e '/\[ERROR\] \[Help 1\]*/d' |
        sed -e 's/Time elapsed:.*s//g')

    jq -n --arg output "${sanitized_output}" '{version: 1, status: "fail", message: $output}' > ${results_file}
fi

echo "${slug}: done"
