# Merge Script

echo "Step 1"
# Set bash script to exit immediately if any commands fail.
set -e

echo "Step 2"
# Setup some constants for use later on.
FRAMEWORK_NAME="$1"

echo "Step 3"
# If remnants from a previous build exist, delete them.
if [ -d "build" ]; then
rm -rf "build"
fi

echo "Step 4"
# Build the framework for device and for simulator (using
# all needed architectures).
xcodebuild -target "${FRAMEWORK_NAME}" -configuration Release -arch arm64 -arch armv7 -arch armv7s only_active_arch=no defines_module=yes -sdk "iphoneos"
xcodebuild -target "${FRAMEWORK_NAME}" -configuration Release -arch x86_64 -arch i386 only_active_arch=no defines_module=yes -sdk "iphonesimulator"

echo "Step 5"
# Remove .framework file if exists in output from previous run.
if [ -d "output/DDMockiOS/${FRAMEWORK_NAME}.framework" ]; then
rm -rf "output/DDMockiOS/${FRAMEWORK_NAME}.framework"
fi

echo "Step 6"
# Copy the device version of framework to output.
cp -r "build/Release-iphoneos/${FRAMEWORK_NAME}.framework" "output/DDMockiOS/${FRAMEWORK_NAME}.framework"

echo "Step 7"
# Replace the framework executable within the framework with
# a new version created by merging the device and simulator
# frameworks' executables with lipo.
lipo -create -output "output/DDMockiOS/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}" "build/Release-iphoneos/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}" "build/Release-iphonesimulator/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}"

echo "Step 8"
# Copy the Swift module mappings for the simulator into the
# framework.  The device mappings already exist from step 6.
cp -r "build/Release-iphonesimulator/${FRAMEWORK_NAME}.framework/Modules/${FRAMEWORK_NAME}.swiftmodule/" "output/DDMockiOS/${FRAMEWORK_NAME}.framework/Modules/${FRAMEWORK_NAME}.swiftmodule"

echo "Step 9"
# Delete the most recent build.
if [ -d "build" ]; then
rm -rf "build"
fi

echo "Done"
