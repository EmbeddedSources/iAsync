LAUNCH_DIR=$PWD

TEMP_DIR=$(/usr/bin/getconf DARWIN_USER_TEMP_DIR)
TEST_DIR_NAME=test-results

TEST_RESULTS_DIR=$TEMP_DIR$TEST_DIR_NAME

cd ../../
   PROJECT_ROOT=$PWD
   
   mkdir deployment
   cd deployment
      DEPLOYMENT_DIR=$PWD
cd "$LAUNCH_DIR"

TEST_PUBLISH_DIR=$DEPLOYMENT_DIR/test-results


rm -r -f "$TEST_PUBLISH_DIR"
mkdir -p "$TEST_PUBLISH_DIR"

cd "$TEST_RESULTS_DIR"
   pwd
   cp *.xml "$TEST_PUBLISH_DIR"
cd "$LAUNCH_DIR"


cd "$DEPLOYMENT_DIR"
   zip -r test-results.zip test-results
cd "$LAUNCH_DIR"
