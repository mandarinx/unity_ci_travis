#! /bin/sh

if [ -z "${CI}" ]; then
    UNITY_PATH="/Applications/Unity/Hub/Editor/2018.2.8f1/Unity.app/Contents/MacOS/Unity"
else
    UNITY_PATH="/Applications/Unity/Unity.app/Contents/MacOS/Unity"
fi
echo "[SYNG2] Unity path: ${UNITY_PATH}"

returnLicense() {
    echo "[SYNG2] Return license"

    ${UNITY_PATH} \
        -logFile "${TRAVIS_BUILD_DIR}/unity.returnlicense.log" \
        -batchmode \
        -returnlicense \
        -quit
    cat "$(pwd)/unity.returnlicense.log"
}

activateLicense() {
    echo "[SYNG2] Activate Unity"

    ${UNITY_PATH} \
        -logFile "${TRAVIS_BUILD_DIR}/unity.activation.log" \
        -serial ${UNITY_SERIAL} \
        -username ${UNITY_USER} \
        -password ${UNITY_PWD} \
        -batchmode \
        -noUpm \
        -quit
    echo "[SYNG2] Unity activation log"
    cat "${TRAVIS_BUILD_DIR}/unity.activation.log"
}

unitTests() {
    echo "[SYNG2] Running editor unit tests for ${UNITY_PROJECT_NAME}"

    ${UNITY_PATH} \
        -batchmode \
        -silent-crashes \
        -serial ${UNITY_SERIAL} \
        -username ${UNITY_USER} \
        -password ${UNITY_PWD} \
        -logFile "${TRAVIS_BUILD_DIR}/unity.unittests.log" \
        -projectPath "${TRAVIS_BUILD_DIR}/${UNITY_PROJECT_NAME}/" \
        -runEditorTests \
        -editorTestsResultFile "${TRAVIS_BUILD_DIR}/unity.unittests.xml"

    rc0=$?
    echo "[SYNG2] Unit test log"
    cat "${TRAVIS_BUILD_DIR}/unity.unittests.xml"

    # exit if tests failed
    if [ $rc0 -ne 0 ]; then { echo "[SYNG2] Unit tests failed"; exit $rc0; } fi
}

prepareBuilds() {
    echo "[SYNG2] Preparing building"

    mkdir ${BUILD_PATH}
    echo "[SYNG2] Created directory: ${BUILD_PATH}"
}

buildiOS() {
    echo "[SYNG2] Building ${UNITY_PROJECT_NAME} for iOS"

    ${UNITY_PATH} \
        -batchmode \
        -silent-crashes \
        -logFile "${TRAVIS_BUILD_DIR}/unity.build.ios.log" \
        -projectPath "${TRAVIS_BUILD_DIR}/${UNITY_PROJECT_NAME}" \
        -executeMethod Syng.Builds.Build \
        -syngBuildPath "${BUILD_PATH}/iOS" \
        -quit

    rc1=$?
    echo "[SYNG2] Build logs (iOS)"
    cat "${TRAVIS_BUILD_DIR}/unity.build.ios.log"

    # exit if build failed
    if [ $rc1 -ne 0 ]; then { echo "[SYNG2] Build failed"; exit $rc1; } fi
}

fastlaneRun() {
    echo "[SYNG2] Copy fastlane setup to iOS project"
    cp -R ./fastlane ${BUILD_PATH}/iOS/
    fastlane beta build_number:${TRAVIS_BUILD_NUMBER} project_path:${BUILD_PATH}/iOS/ build_root:${TRAVIS_BUILD_DIR}/
}

# ------------------------------------------------------------------------------

activateLicense
unitTests
prepareBuilds
buildiOS
returnLicense
fastlaneRun

exit 0
