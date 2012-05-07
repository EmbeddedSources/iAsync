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


IOS_VERSION=5.1
CONFIGURATION=Debug

OLD_XCODE_PATH=$(xcode-select -print-path)
#latest stable xcode
#sudo xcode-select -switch "/Applications/Xcode/Contents/Developer"

rm -rf "$PROJECT_ROOT/deployment"
mkdir -p "$PROJECT_ROOT/deployment/test-results"

/bin/bash "$SCRIPTS_ROOT_DIR/simulator/CleanTestReports.sh"
    /bin/bash "$PWD/RunJUiTest.sh" $IOS_VERSION $CONFIGURATION
    if [ "$?" -ne "0" ]; then 
       echo "[!!! ERROR !!!] : JFFUtilsTest.sh failed"
       exit 1
    fi
    
    /bin/bash "$PWD/RunJUtilsTest.sh" $IOS_VERSION $CONFIGURATION
    if [ "$?" -ne "0" ]; then 
       echo "[!!! ERROR !!!] : JFFUtilsTest.sh failed"
       exit 1
    fi

    /bin/bash "$PWD/RunJNetworkTest.sh" $IOS_VERSION $CONFIGURATION
    if [ "$?" -ne "0" ]; then 
       echo "[!!! ERROR !!!] : RunJNetworkTest.sh failed"
       exit 1
    fi
    
    /bin/bash "$PWD/RunJAsyncTest.sh" $IOS_VERSION $CONFIGURATION
    if [ "$?" -ne "0" ]; then 
       echo "[!!! ERROR !!!] : RunJAsyncTest.sh failed"
       exit 1
    fi 

/bin/bash "$SCRIPTS_ROOT_DIR/simulator/CopyTestReports.sh"

#restore settings
#sudo xcode-select -switch "$OLD_XCODE_PATH"

