LAUNCH_DIR=$PWD

cd ../../
   PROJECT_ROOT=$PWD

   if [ ! -d "deployment" ]; then   
      mkdir deployment
   fi

   cd deployment
      DEPLOYMENT_DIR=$PWD
cd "$LAUNCH_DIR"

TEST_PUBLISH_DIR=$DEPLOYMENT_DIR/test-results


rm -r -f "$TEST_PUBLISH_DIR"
mkdir -p "$TEST_PUBLISH_DIR"



cd ~/Library/Application\ Support/iPhone\ Simulator/7.0.3/Applications
for directory in $( ls -1 ); do
   echo "$directory/tmp/test-results"
   ls -1 "$directory/tmp/test-results"

   for report in $( ls -1 "$directory/tmp/test-results/" ); do
       cp "$directory/tmp/test-results/$report" "$TEST_PUBLISH_DIR"
   done

   echo "============================"
done
cd "$LAUNCH_DIR"

cd "$DEPLOYMENT_DIR"
   zip -r test-results.zip test-results
cd "$LAUNCH_DIR"
