#!/bin/sh
# Keep the Travis job open until Travis has archived this job's own log up to
# the QUnit summary. Travis aggregates log parts asynchronously, minutes
# behind the job; a log fetched right after the job ends is cut off before the
# test results. Runs as after_script, which cannot change the build result.
url="https://api.travis-ci.com/v3/job/${TRAVIS_JOB_ID}/log.txt"
if [ "${TRAVIS_TEST_RESULT:-0}" = "0" ]; then
  marker='Tests: [0-9][0-9]* passed, [0-9][0-9]* failed'
else
  marker='exited with [1-9]'
fi
i=0
while [ "$i" -lt 120 ]; do
  if curl -sfL "$url" | grep -q "$marker"; then
    echo "seal: job log archived through the test summary"
    exit 0
  fi
  i=$((i + 1))
  sleep 20
done
echo "seal: gave up waiting for the job log to be archived"
