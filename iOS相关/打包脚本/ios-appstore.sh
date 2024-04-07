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

#iOS关联依赖
cd "${WORKSPACE}/ios"
pod install

#移除百度OCR x86_64, i386 架构
cd "${WORKSPACE}/ios/Framework/BaiduAi/OCR"
lipo -info AipBase.framework/AipBase
lipo -info AipOcrSdk.framework/AipOcrSdk

lipo -remove x86_64 AipBase.framework/AipBase -o AipBase.framework/AipBase
lipo -remove i386 AipBase.framework/AipBase -o AipBase.framework/AipBase
lipo -remove x86_64 AipOcrSdk.framework/AipOcrSdk -o AipOcrSdk.framework/AipOcrSdk
lipo -remove i386 AipOcrSdk.framework/AipOcrSdk -o AipOcrSdk.framework/AipOcrSdk

lipo -info AipBase.framework/AipBase
lipo -info AipOcrSdk.framework/AipOcrSdk

#移除顶象 x86_64, i386 架构
#cd "${WORKSPACE}/ios/Framework/DXRisk"
#lipo -info DXRiskWithIDFA.framework/DXRiskWithIDFA

#lipo -remove x86_64 DXRiskWithIDFA.framework/DXRiskWithIDFA -o DXRiskWithIDFA.framework/DXRiskWithIDFA
#lipo -remove i386 DXRiskWithIDFA.framework/DXRiskWithIDFA -o DXRiskWithIDFA.framework/DXRiskWithIDFA

#lipo -info DXRiskWithIDFA.framework/DXRiskWithIDFA



####### .sh


PROJECT="${WORKSPACE}/ios/gktapp.xcworkspace"
SCHEME="gktapp"
IDENTITY="Apple Development: roc jion (734J4J5RB8)"
GKTAPP_PRD="/Users/jion/workspace/signature/20220923/gktapp.mobileprovision"
ARCHIVEPATH="${WORKSPACE}/ios/build/archive"
OUTDIR="${WORKSPACE}/ios/build/ipa"
INFOPLIST_FILE="${WORKSPACE}/ios/gktapp/Info.plist"
PACKAGE_FILE="${WORKSPACE}/package.json"
PLIST_PATH="/Users/jion/.jenkins/workspace/ExportOptions.plist"


#证书判断
if [ ! -f $GKTAPP_PRD ]; then
    echo "Please download the provision file for "${GKTAPP_PRD}
    exit 4;
fi

# 版本号修改一致
# Type a script or drag a script file from your workspace to insert its path.
PACKAGE_VERSION=$(cat ${PACKAGE_FILE} | grep version | head -1 | awk -F: '{ print $2 }' | sed 's/[\",]//g' | tr -d '[[:space:]]')
PACKAGE_BUILD=$(cat ${PACKAGE_FILE} | grep build | head -1 | awk -F: '{ print $2 }' | sed 's/[\",]//g' | tr -d '[[:space:]]')
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $PACKAGE_VERSION" "${PROJECT_DIR}/${INFOPLIST_FILE}"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $PACKAGE_BUILD" "${PROJECT_DIR}/${INFOPLIST_FILE}"

#获取钥匙串和打包电脑密码
security unlock-keychain -p "123456" $keychainPath

#clean
xcodebuild  -workspace "${PROJECT}" -scheme "${SCHEME}" -configuration Release clean
#archive
xcodebuild archive -workspace "${PROJECT}" -scheme "${SCHEME}" -configuration Release -archivePath "${ARCHIVEPATH}/${SCHEME}.xcarchive" -quiet
#export
xcodebuild -exportArchive -archivePath "${ARCHIVEPATH}/${SCHEME}.xcarchive" -exportPath "${OUTDIR}" -exportOptionsPlist "${PLIST_PATH}" -quiet


#拷贝store包
ipaName=`date +%Y-%m-%d.ipa`

#上传到AppStore
IPAPATH="${OUTDIR}/${SCHEME}.ipa"

apiKey="58JFDGGLX4"
apiIssuer="8670fd90-9ee7-4b10-ab8d-0ac5bf17dc67"

#验证信息
xcrun altool --validate-app -f "${IPAPATH}" -t ios --apiKey "${apiKey}" --apiIssuer "${apiIssuer}" --verbose  --output-format xml

#上传iTunesConnect
xcrun altool --upload-app -f "${IPAPATH}" -t ios --apiKey "${apiKey}" --apiIssuer "${apiIssuer}" --verbose  --output-format xml

#cp ${OUTDIR}/${SCHEME}.ipa "/Users/jion/workspace/gktapp-release/ios-store/store_gtkapp_"$ipaName

