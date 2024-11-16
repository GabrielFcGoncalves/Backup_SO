#!/bin/bash
# test_a1.sh

testName=test_a1

# Remove the line that deletes backup_test
# rm -rf backup_test

cp -r -a backup_$testName backup_test

# Test results
./backup_summary.sh src backup_test > output.txt 2> err.txt

nlinesout=$(wc -l ${testName}.out | cut -d\  -f1)

# Output information (displaying the output to preserve all information)
echo "Output from backup_summary.sh:"
cat output.txt

# Test results
# Correct in head
if cat output.txt | grep . | head -${nlinesout} | tr -s ' ' | sort | diff - ${testName}.out > /dev/null
then
    score=$((score+60))
# Correct in tail
elif cat output.txt | grep . | tail -${nlinesout} | tr -s ' ' | sort | diff - ${testName}.out > /dev/null
then
    score=$((score+60))
fi

# Displaying directory comparison results
echo "Comparing directory contents..."
if [[ "$(ls -l backup_test)" == "$(ls -l src)" ]]
then
    score=$((score+25))
    echo "Directory contents match."
else
    echo "Directory contents do not match."
fi

echo "Comparing 'aaa' subdirectory..."
if [[ "$(ls -l backup_test/aaa)" == "$(ls -l src/aaa)" ]]
then
    score=$((score+15))
    echo "'aaa' subdirectory contents match."
else
    echo "'aaa' subdirectory contents do not match."
fi

# Display any errors
echo "Error Output:"
cat err.txt

# No need to remove backup_test
# rm -rf backup_test

echo "Score: $score"
