#设置编码格式 utf-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8


#!/bin/bash -ilex
#进入项目所在目录
cd "${WORKSPACE}"
#加载依赖modules
yarn install


#!/bin/bash -ilex

#强制拷贝aip..license
cp -f /Users/jion/.jenkins/workspace/aip.license ${WORKSPACE}/android/app/assets/

#拷贝local.properties
cp /Users/jion/.jenkins/workspace/local.properties ${WORKSPACE}/android/

#rm -rf ${WORKSPACE}/android/app/libs/x86/

#打包Android
cd "${WORKSPACE}/android"

#创建包输出目录
./gradlew clean

#编译32位包
./gradlew assemblePrdRelease

#编译64位包
./gradlew assemblePrd64Release


#!/bin/bash -ilex

case $Protective in
   Yes)
      {
         echo '================need protective, start delete last build signed protective apk================'
         #删除上个版本签名加固包
         find /Users/jion/workspace/gktapp-release/android-store -name "*.apk" | xargs rm -rf

         echo '================need protective, start delete last build no signed protective apk================'
	dir_path="/Users/jion/workspace/gktapp-release/android-store/unsigned"
	# 检查目录是否存在

	if [ ! -d "$dir_path" ]; then

    	  # 如果目录不存在，创建它

    	  mkdir -p "$dir_path"

    	  echo "Directory $dir_path created."

	else

    	 #删除非签名加固包
         find /Users/jion/workspace/gktapp-release/android-store/unsigned -name "*.apk" | xargs rm -rf

	fi

      }
   ;;
   No)
      {
         echo '================no need protective, start delete last build apk================'
         #删除上个版本签名加固包
         find /Users/jion/workspace/gktapp-release/android-store -name "*.apk" | xargs rm -rf
      }
      ;;
   *)
      exit
      ;;
esac


#!/bin/bash -ilex
case $Protective in
   Yes)
      {
         echo '================need protective, start use DX protective technology for channel apk================'
         #使用顶象加固32位包
         #!/bin/bash -ilex
         cd "/Users/jion/.jenkins/workspace/multi_channel_private"
         outPutPath="/Users/jion/workspace/gktapp-release/android-store"
         inPutApk=${WORKSPACE}/android/app/build/outputs/apk/prd/release/app-prd-release.apk
         outPutApk=${outPutPath}/unsigned/store_gtkapp_prd.apk
         dXTool="/Users/jion/.jenkins/workspace/multi_channel_private"

         #32位包加固
         python ${dXTool}/appensys_cli.py --package-type=android_app --host-url=http://appen.dingxiang-inc.com --account=18721756393 --password=Ld1234567 --strategy-id=0 -i  ${inPutApk} -o ${outPutApk} --channel-path=${dXTool}/android-appen-tools/channel.txt --channel-name=UMENG_CHANNEL
         #重新签名
         java -jar -Dfile.encoding=utf-8 ${dXTool}/android-appen-tools/dx-wallent-ci-apk-signer.jar --in ${outPutPath}/unsigned --o ${outPutPath} --k ${dXTool}/android-appen-tools/greenland.jks --v2 --s greenland-financial --a green-land-financial --p greenland-financial
      }
      ;;
   No)
      {
         echo '================no need protective，copy file and upload to fir================'
         inPutApk=${WORKSPACE}/android/app/build/outputs/apk/prd/release/app-prd-release.apk
         outPutPathApk="/Users/jion/workspace/gktapp-release/android-store"/store_gtkapp_prd.apk
         cp ${inPutApk}  ${outPutPathApk}
      }
      ;;
   *)
      exit
      ;;
esac


#!/bin/bash -ilex
case $Protective in
   Yes)
      {
         echo '================need protective, start use DX protective technology for channel apk================'
         #使用顶象加固64位包
         #!/bin/bash -ilex
         cd "/Users/jion/.jenkins/workspace/multi_channel_private"
         outPutPath="/Users/jion/workspace/gktapp-release/android-store"
         inPutApk=${WORKSPACE}/android/app/build/outputs/apk/prd64/release/app-prd64-release.apk
         outPutApk=${outPutPath}/unsigned/store_gtkapp_prd64.apk
         dXTool="/Users/jion/.jenkins/workspace/multi_channel_private"

         #64位包加固
         python ${dXTool}/appensys_cli.py --package-type=android_app --host-url=http://appen.dingxiang-inc.com --account=18721756393 --password=Ld1234567 --strategy-id=0 -i  ${inPutApk} -o ${outPutApk} --channel-path=${dXTool}/android-appen-tools/channel.txt --channel-name=UMENG_CHANNEL
         #重新签名
         java -jar -Dfile.encoding=utf-8 ${dXTool}/android-appen-tools/dx-wallent-ci-apk-signer.jar --in ${outPutPath}/unsigned --o ${outPutPath} --k ${dXTool}/android-appen-tools/greenland.jks --v2 --s greenland-financial --a green-land-financial --p greenland-financial
      }
      ;;
   No)
      {
         echo '================no need protective，copy file and upload to fir================'
         inPutApk=${WORKSPACE}/android/app/build/outputs/apk/prd64/release/app-prd64-release.apk
         outPutPathApk="/Users/jion/workspace/gktapp-release/android-store"/store_gtkapp_prd64.apk
         cp ${inPutApk}  ${outPutPathApk}
      }
      ;;
   *)
      exit
      ;;
esac




#!/bin/bash --login
#上传签名加固包到fir
cd "/Users/jion/workspace/gktapp-release/android-store"

echo '================start upload apk to fir================'

# 可更换账号
fir login 85632c75fa725291277821caxxxxxxxx
#fir publish store_gtkapp_prd.apk
fir publish store_gtkapp_prd64.apk
