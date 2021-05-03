#!/bin/bash

echo
echo "### DOWNLOAD IOS SOURCE (via Carthage) ###"
echo

output_folder="iOS_Carthage"
echo "output_folder = $output_folder"

mkdir -p $output_folder
echo "github \"NordicSemiconductor/IOS-Pods-DFU-Library\" == 4.10.1" > $output_folder/Cartfile
pushd $output_folder
carthage update --use-xcframeworks --platform iOS
popd

echo
echo "### CREATE FAT LIBRARIES iOSDFULibrary ###"
echo

iphoneos_framework=`find ./$output_folder/Carthage/Build/iOSDFULibrary.xcframework/ -ipath "*arm64_armv7*" -iname "iOSDFULibrary.framework" | head -n 1`
iphonesimulator_framework=`find ./$output_folder/Carthage/Build/iOSDFULibrary.xcframework/ -ipath "*i386_x86_64*" -iname "iOSDFULibrary.framework" | head -n 1`

if [ ! -d "$iphoneos_framework" ]; then
    echo "Failed : $iphoneos_framework does not exist"
    exit 1
fi
if [ ! -d "$iphonesimulator_framework" ]; then
    echo "Failed : $iphonesimulator_framework does not exist"
    exit 1
fi

fat_lib_path="$output_folder/Carthage/Build/iOSDFULibrary.xcframework/ios-fat"
rm -rf $fat_lib_path
cp -a $(dirname $iphoneos_framework)/. $fat_lib_path

rm -rf $fat_lib_path/iOSDFULibrary.framework/iOSDFULibrary
lipo -create -output $fat_lib_path/iOSDFULibrary.framework/iOSDFULibrary $iphoneos_framework/iOSDFULibrary $iphonesimulator_framework/iOSDFULibrary
lipo -info $fat_lib_path/iOSDFULibrary.framework/iOSDFULibrary

echo
echo "### CREATE FAT LIBRARIES ZIPFoundation ###"
echo

iphoneos_framework=`find ./$output_folder/Carthage/Build/ZIPFoundation.xcframework/ -ipath "*arm64_armv7*" -iname "ZIPFoundation.framework" | head -n 1`
iphonesimulator_framework=`find ./$output_folder/Carthage/Build/ZIPFoundation.xcframework/ -ipath "*i386_x86_64*" -iname "ZIPFoundation.framework" | head -n 1`

if [ ! -d "$iphoneos_framework" ]; then
    echo "Failed : $iphoneos_framework does not exist"
    exit 1
fi
if [ ! -d "$iphonesimulator_framework" ]; then
    echo "Failed : $iphonesimulator_framework does not exist"
    exit 1
fi

fat_lib_path="$output_folder/Carthage/Build/ZIPFoundation.xcframework/ios-fat"
rm -rf $fat_lib_path
cp -a $(dirname $iphoneos_framework)/. $fat_lib_path

rm -rf $fat_lib_path/ZIPFoundation.framework/ZIPFoundation
lipo -remove arm64 -output $iphonesimulator_framework/ZIPFoundation $iphonesimulator_framework/ZIPFoundation
lipo -create -output $fat_lib_path/ZIPFoundation.framework/ZIPFoundation $iphoneos_framework/ZIPFoundation $iphonesimulator_framework/ZIPFoundation
lipo -info $fat_lib_path/ZIPFoundation.framework/ZIPFoundation


iOSDFULibrary_fat_framework=`find ./$output_folder/Carthage/Build/iOSDFULibrary.xcframework/ios-fat -iname "iOSDFULibrary.framework" | head -n 1`
if [ ! -d "$iOSDFULibrary_fat_framework" ]; then
    echo "Failed : iOSDFULibrary_fat_framework does not exist"
    exit 1
fi
iOSDFULibrary_fat_framework_dsym=`find ./$output_folder/Carthage/Build/iOSDFULibrary.xcframework/ios-fat -iname "iOSDFULibrary.framework.dSYM" | head -n 1`
if [ ! -d "$iOSDFULibrary_fat_framework_dsym" ]; then
    echo "Failed : iOSDFULibrary_fat_framework_dsym does not exist"
    exit 1
fi
ZIPFoundation_fat_framework=`find ./$output_folder/Carthage/Build/ZIPFoundation.xcframework/ios-fat -iname "ZIPFoundation.framework" | head -n 1`
if [ ! -d "$ZIPFoundation_fat_framework" ]; then
    echo "Failed : ZIPFoundation_fat_framework does not exist"
    exit 1
fi
ZIPFoundation_fat_framework_dsym=`find ./$output_folder/Carthage/Build/ZIPFoundation.xcframework/ios-fat -iname "ZIPFoundation.framework.dSYM" | head -n 1`
if [ ! -d "$ZIPFoundation_fat_framework_dsym" ]; then
    echo "Failed : ZIPFoundation_fat_framework_dsym does not exist"
    exit 1
fi

echo "Created :"
echo "  - $iOSDFULibrary_fat_framework"
echo "  - $ZIPFoundation_fat_framework"
echo "  - $iOSDFULibrary_fat_framework_dsym"
echo "  - $ZIPFoundation_fat_framework_dsym"
