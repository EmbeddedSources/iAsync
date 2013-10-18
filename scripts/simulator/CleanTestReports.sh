## TEMP_DIR=$(/usr/bin/getconf DARWIN_USER_TEMP_DIR)
## TEST_DIR_NAME=test-results

## TEST_RESULTS_DIR=$TEMP_DIR$TEST_DIR_NAME

## rm -r -f "$TEST_RESULTS_DIR"

cd ~/Library/Application\ Support/iPhone\ Simulator/7.0/
rm -rf Applications
mkdir -p Applications
