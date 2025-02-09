#!/bin/sh
set -o pipefail
set -e

BUILD_ENV=$1

rm -rf build
mkdir build
cp -r ../Sources/AliNetworkDiagnosis/AliNetworkDiagnosis.xcframework build/AliNetworkDiagnosis.xcframework
cp -r ../Sources/WPKMobi/WPKMobi.xcframework build/WPKMobi.xcframework

sh build-producer.sh
sh build-ot.sh
sh build-ot-swift.sh
sh build-core.sh
#sh build-crashreporter.sh
sh build-networkdiagnosis.sh
#sh build-trace.sh
#sh build-urlsession.sh

if [[ ${#BUILD_ENV} == 0 ]];
then
    echo "building in native..."
    env=lint pod lib lint AliyunLogProducer.podspec --allow-warnings
else
    echo "building in mtl..."
    env=lint tpod lib lint AliyunLogProducer.podspec --allow-warnings
fi

mkdir -p out

pushd build
zip -r ../out/xcframeworks.zip *
popd

mkdir -p build/zip/AliNetworkDiagnosis && cp -r build/AliNetworkDiagnosis.xcframework build/zip/AliNetworkDiagnosis/AliNetworkDiagnosis.xcframework
mkdir -p build/zip/WPKMobi && cp -r build/WPKMobi.xcframework build/zip/WPKMobi/WPKMobi.xcframework

mkdir -p build/zip/AliyunLogProducer && cp -r build/AliyunLogProducer.xcframework build/zip/AliyunLogProducer/AliyunLogProducer.xcframework
mkdir -p build/zip/AliyunLogOT && cp -r build/AliyunLogOT.xcframework build/zip/AliyunLogOT/AliyunLogOT.xcframework
mkdir -p build/zip/AliyunLogOTSwift && cp -r build/AliyunLogOTSwift.xcframework build/zip/AliyunLogOTSwift/AliyunLogOTSwift.xcframework
mkdir -p build/zip/AliyunLogCore && cp -r build/AliyunLogCore.xcframework build/zip/AliyunLogCore/AliyunLogCore.xcframework
#mkdir -p build/zip/AliyunLogCrashReporter && cp -r build/AliyunLogCrashReporter.xcframework build/zip/AliyunLogCrashReporter/AliyunLogCrashReporter.xcframework
mkdir -p build/zip/AliyunLogNetworkDiagnosis && cp -r build/AliyunLogNetworkDiagnosis.xcframework build/zip/AliyunLogNetworkDiagnosis/AliyunLogNetworkDiagnosis.xcframework
#mkdir -p build/zip/AliyunLogTrace && cp -r build/AliyunLogTrace.xcframework build/zip/AliyunLogTrace/AliyunLogTrace.xcframework
#mkdir -p build/zip/AliyunLogURLSession && cp -r build/AliyunLogURLSession.xcframework build/zip/AliyunLogURLSession/AliyunLogURLSession.xcframework

pushd build/zip
zip -r ../../out/AliyunLogProducer.zip *
popd

# open build/zip
