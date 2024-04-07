#!/bin/bash -ilex

# code-push: https://www.wddsss.com/main/displayArticle/224

#设置编码格式 utf-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8


#进入项目所在目录
cd "${WORKSPACE}"
#加载依赖modules
yarn install

#获取bundleVersion&bundleComment
PACKAGE_FILE="${WORKSPACE}/package.json"

APP_VERSION=$(cat ${PACKAGE_FILE} | grep version | head -1 | awk -F: '{ print $2 }' | sed 's/[\",]//g' | tr -d '[[:space:]]')
BUNDLE_VERSION=$(cat ${PACKAGE_FILE} | grep bundleVersion | head -1 | awk -F: '{ print $2 }' | sed 's/[\",]//g' | tr -d '[[:space:]]')
BUNDLE_COMMENT=$(cat ${PACKAGE_FILE} | grep bundleComment | head -1 | awk -F: '{ print $2 }' | sed 's/[\",]//g' | tr -d '[[:space:]]')

{
#判断codepush是否登录
LOGIN_NAME=`code-push whoami`
}||{
LOGIN_NAME='Error'
}
echo 'LOGINNAME: $LOGIN_NAME';
if test "$LOGIN_NAME" = "Error"
then echo '未登录';
else echo '已登录';
code-push logout
fi
code-push login https://codepush.xxxx.com --accessKey code-push的accesskey


#上传codepush
if test "$Env" = "UAT"
then echo "发布UAT版本";
code-push release-react app-ios ios -d Production -t ${APP_VERSION} --des "$APP_VERSION.$BUNDLE_VERSION 版本：$BUNDLE_COMMENT" -m $ForceUpdate
code-push release-react app-android android -d Production -t ${APP_VERSION} --des "$APP_VERSION.$BUNDLE_VERSION 版本：$BUNDLE_COMMENT" -m $ForceUpdate
else echo "发布测试版本";
code-push release-react app-ios ios -d Staging -t ${APP_VERSION} --des "$APP_VERSION.$BUNDLE_VERSION 版本：$BUNDLE_COMMENT" -m $ForceUpdate
code-push release-react app-android android -d Staging -t ${APP_VERSION} --des "$APP_VERSION.$BUNDLE_VERSION 版本：$BUNDLE_COMMENT" -m $ForceUpdate
fi

#上传生产codepush
#code-push release-react app-ios ios -d Production -t ${APP_VERSION} --des "$APP_VERSION.$BUNDLE_VERSION 版本：$BUNDLE_COMMENT" -m $forceUpdate
#code-push release-react app-android android -d Production -t ${APP_VERSION} --des "$APP_VERSION.$BUNDLE_VERSION 版本：$BUNDLE_COMMENT" -m $forceUpdate
