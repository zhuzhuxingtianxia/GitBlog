#!/bin/bash -ilex

#设置编码格式 utf-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

#进入项目所在目录
cd "${WORKSPACE}"
#加载依赖modules
yarn install
#关联依赖
#react-native link

#gradle -v

cd "${WORKSPACE}/ios"
pod install

# 内部测试使用包持续集成, 蒲公英内测版，Android不加固重新加签，iOS内测证书
# iOS
#!/bin/bash
PROJECT="${WORKSPACE}/ios/gktapp.xcworkspace"
SCHEME="gktdev"
IDENTITY="iPhone Developer: xiaoqiang wang (HUHM9R47CV)"
PLIST_PATH="/Users/jion/.jenkins/workspace/ExportOptionsDev.plist"
ARCHIVEPATH="${WORKSPACE}/ios/build/archive"
OUTDIR="${WORKSPACE}/ios/build/ipa"
INFOPLIST_FILE="${WORKSPACE}/ios/gktdev-Info.plist"
PACKAGE_FILE="${WORKSPACE}/package.json"
IOS_PATH="${WORKSPACE}/ios"

# 版本号修改一致
# Type a script or drag a script file from your workspace to insert its path.
PACKAGE_VERSION=$(cat ${PACKAGE_FILE} | grep version | head -1 | awk -F: '{ print $2 }' | sed 's/[\",]//g' | tr -d '[[:space:]]')
PACKAGE_BUILD=$(cat ${PACKAGE_FILE} | grep build | head -1 | awk -F: '{ print $2 }' | sed 's/[\",]//g' | tr -d '[[:space:]]')
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $PACKAGE_VERSION" "${INFOPLIST_FILE}"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $PACKAGE_BUILD" "${INFOPLIST_FILE}"

#获取钥匙串和打包电脑密码
security unlock-keychain -p "123456" $keychainPath

#clean
xcodebuild -workspace "${PROJECT}" -scheme "${SCHEME}" -configuration Release clean

#强制开启bitcode
#/Users/songjunpeng/Downloads/ExoskeletonCmd "${IOS_PATH}"

#archive
xcodebuild archive -workspace "${PROJECT}" -scheme "${SCHEME}" -configuration Release -archivePath "${ARCHIVEPATH}/${SCHEME}.xcarchive" -quiet
#export
xcodebuild -exportArchive -archivePath "${ARCHIVEPATH}/${SCHEME}.xcarchive" -exportPath "${OUTDIR}" -exportOptionsPlist "${PLIST_PATH}" -quiet

#拷贝store包
#ipaName=`date +%Y-%m-%d.ipa`

# Android
#!/bin/bash -ilex
#拷贝local.properties
cp /Users/jion/.jenkins/workspace/local.properties ${WORKSPACE}/android/
#打包Android
cd "${WORKSPACE}/android"

security unlock-keychain -p "123456" $keychainPath

#创建包输出目录
if [ ! -d "${WORKSPACE}/android/app/build" ]; then
    ./gradlew clean
fi

#更换包名为gktdev
./gradlew replacePackageName -PcurrentPackageName="gktapp" -PreplacePackageName="gktdev"

#gradle assembleRelease --console plain
./gradlew assembleDevRelease
#拷贝release包到加固重签目录
#apkName=`date +%Y-%m-%d.apk`

#拷贝一份到上传目录
#cp ${WORKSPACE}/android/app/build/outputs/apk/release/app-release.apk ${WORKSPACE}/output/gktapp.apk
#cp ${WORKSPACE}/android/app/build/outputs/apk/app-release.apk "/Users/songjunpeng/workspace/gktapp-release/android-release/uat_gtkapp_"$apkName


# 上传fir-ios
#!/bin/bash --login

cd "${WORKSPACE}/ios/build/ipa"

fir login 85632c75fa725291277821ca8b553fab

fir publish gktdev.ipa


# 上传fir-android
#!/bin/bash --login

cd "${WORKSPACE}/android/app/build/outputs/apk/dev/release/"

fir login 85632c75fa725291277821caxxxxxxxx

fir publish app-dev-release.apk
