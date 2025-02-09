#!/bin/sh
BIN_OUTPUT_DIRECTORY=`pwd`
cd ..

APPLICATION_NAME="AliyunLogProducer"
SCHEME="Unity4SLS"
WORKSPACE="AliyunLogSDK.xcodeproj"
PROJECT_BUILDDIR="./publish/build"

rm -rf lib${SCHEME}.a

xcodebuild  -project ${WORKSPACE} -scheme ${SCHEME} -configuration Release -sdk iphoneos clean build CONFIGURATION_BUILD_DIR="${PROJECT_BUILDDIR}/iphoneos"
xcodebuild  -project ${WORKSPACE} -scheme ${SCHEME} -configuration Release -sdk iphonesimulator clean build CONFIGURATION_BUILD_DIR="${PROJECT_BUILDDIR}/iphonesimulator"

cp ./Sources/Unity4SLS/include/Unity4SLSiOS.h ${PROJECT_BUILDDIR}/Unity4SLSiOS.h

cd ./${PROJECT_BUILDDIR}

lipo -remove arm64 ./iphonesimulator/lib${SCHEME}.a -output ./iphonesimulator/lib${SCHEME}.a
lipo -create iphoneos/lib${SCHEME}.a iphonesimulator/lib${SCHEME}.a -output lib${SCHEME}.a

rm -rf iphoneos
rm -rf iphonesimulator

#cd ..
#sh strip_symbols.sh AliyunLogProducer ../../exported_symbols/producer_symbols.txt

