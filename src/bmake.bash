#!/bin/bash

bsub_out="$(bsub make "$@")"
jobid="$(echo "$bsub_out" | sed 's/>.*//' | sed 's/.*<//')"

# Wait for the job to start
while [[ "$(bjobs -o stat $jobid | grep "^PEND$" | wc -l)" == 1 ]]
do
    sleep 1s
done

# Display the output of the job to stdout
(
    bpeek -f $jobid
) &

# Wait for the job to finish
while [[ "$(bjobs -o stat $jobid | grep "^RUN$" | wc -l)" == 1 ]]
do
    sleep 1s
done

exit_code="$(bjobs -o exit_code $jobid | tail -n1)"
exit $exit_code