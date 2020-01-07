#!/bin/sh -l

set -e
set -x

# Github Action argumens
export PROJECT_PATH="$1"
export BUILD_TARGET="$2"
set +x
export UNITY_LICENSE="$3"
set -x

# Setup unity
mkdir -p /root/.cache/unity3d
mkdir -p /root/.local/share/unity3d/Unity/
set +x
echo "$UNITY_LICENSE" | tr -d '\r' >/root/.local/share/unity3d/Unity/Unity_lic.ulf
unset UNITY_LICENSE
set -x

# Takes the method name as argument
run () {
  METHOD=$1
  ${UNITY_EXECUTABLE:-xvfb-run --auto-servernum --server-args='-screen 0 640x480x24' /opt/Unity/Editor/Unity} \
    -batchmode \
    -nographics \
    -projectPath $PROJECT_PATH \
    -executeMethod $METHOD \
    -quit
  
  UNITY_EXIT_CODE=$?

  case $UNITY_EXIT_CODE in
    0) echo "Run succeeded, no failures occurred";
      ;;
    2) echo "Run succeeded, some tests failed";
      ;;
    3) echo "Run failure (other failure)";
      ;;
    *) echo "Unexpected exit code $UNITY_EXIT_CODE";
      ;;
  esac
}

case $BUILD_TARGET in
  server)
    run BuildScript.PerformServerBuild
    ;;
  windows)
    run BuildScript.PerformWindowsBuild
    ;;
  osx)
    run BuildScript.PerformOSXBuild
    ;;
  linux)
    run BuildScript.PerformLinuxBuild
    ;;
  *)
    echo "Unknown target $BUILD_TARGET"
    ;;
esac

# Hardcoded in all build methods
export BUILD_PATH=Tools/ContentBuilder/content

ls -lA $BUILD_PATH

# Fail job if build folder is empty
set +e
[ -n "$(ls -A $BUILD_PATH)" ]

echo ::set-output name=build-path::"$BUILD_PATH"
