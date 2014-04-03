#!/bin/bash
#
#
#####################

LAUNCH_DIR=$PWD

cd ../
  SCRIPTS_ROOT_DIR=$PWD
cd "$LAUNCH_DIR"

cd ../../
    PROJECT_ROOT=$PWD
cd "$LAUNCH_DIR"

GCOVR=$SCRIPTS_ROOT_DIR/gcovr

# IOS_VERSION=5.1
CONFIGURATION=Debug

OLD_XCODE_PATH=$(xcode-select -print-path)

rm -rf "$PROJECT_ROOT/deployment"
mkdir -p "$PROJECT_ROOT/deployment/test-results"

/bin/bash "$SCRIPTS_ROOT_DIR/simulator/CleanTestReports.sh"
    /bin/bash "$PWD/RunJUiTest.sh" "$IOS_VERSION" "$CONFIGURATION"
    if [ "$?" -ne "0" ]; then 
       echo "[!!! ERROR !!!] : JFFUtilsTest.sh failed"
       exit 1
    fi
    
    /bin/bash "$PWD/RunJUtilsTest.sh" "$IOS_VERSION" "$CONFIGURATION"
    if [ "$?" -ne "0" ]; then 
       echo "[!!! ERROR !!!] : JFFUtilsTest.sh failed"
       exit 1
    fi

    /bin/bash "$PWD/RunJNetworkTest.sh" "$IOS_VERSION" "$CONFIGURATION"
    if [ "$?" -ne "0" ]; then 
       echo "[!!! ERROR !!!] : RunJNetworkTest.sh failed"
       exit 1
    fi
    
    /bin/bash "$PWD/RunJAsyncTest.sh" "$IOS_VERSION" "$CONFIGURATION"
    if [ "$?" -ne "0" ]; then 
       echo "[!!! ERROR !!!] : RunJAsyncTest.sh failed"
       exit 1
    fi 

/bin/bash "$SCRIPTS_ROOT_DIR/simulator/CopyTestReports.sh"


################  COVERAGE
echo "---Collecting coverage reports---"

cd "$PROJECT_ROOT"
    echo "$GCOVR $PWD --root=$PWD --xml > $PWD/Coverage.xml"
	echo "$GCOVR $PWD --root=$PWD       > $PWD/Coverage.txt"

	$GCOVR "$PWD" --root="$PWD" --xml | tee "$PWD/Coverage.xml"
	$GCOVR "$PWD" --root="$PWD"       | tee "$PWD/Coverage.txt"
cd "$LAUNCH_DIR"

echo "---Done---"
exit 0
##################################

