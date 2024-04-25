#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""

Usage: appensys_cli.py [options]

顶象加固系统命令行，支持SAAS、私有化盒子

Options:
  --version             show program's version number and exit
  -h, --help            show this help message and exit
  -i INPUT, --input=INPUT
                        加固前文件（输入） *.apk/zip/aar/xcarchive
  -o OUTPUT, --output=OUTPUT
                        加固后文件保存位置（输出）
  --host-url=HOST_URL   加固的服务端
  --dx-saas             等价于 --host-url=http://appen.dingxiang-inc.com
  -s STRATEGY_ID, --strategy-id=STRATEGY_ID
                        策略编号
  -t PACKAGE_TYPE, --package-type=PACKAGE_TYPE
                        文件类型：android_app, android_sdk, ios_app, ios_sdk,
                        binary, android_scan
  -a ACCOUNT, --account=ACCOUNT
                        账户
  -p PASSWORD, --password=PASSWORD
                        密码
  --class-list-json=CLASS_LIST_JSON
                        [android_sdk] 保护的类名列表，json格式
  --entry-class=ENTRY_CLASS
                        [android_sdk] 入口类名
  -b, --keep-bitcode-in-output
                        [ios_app, ios_sdk] 加固后是否开启bitcode, 默认不保留
  --xcode=XCODE         [ios_app, ios_sdk] 打包使用的Xcode版本
                            7: Xcode 12.0-12.1
                            6: Xcode 11.4
                            5: Xcode 11.0-11.3
                            4: Xcode 10.2-10.3
                            3: Xcode 10.0-10.1
                            2：Xcode 9.x 废弃
                            1：Xcode 9.x 废弃
  --saas-accounting-by-package
                        [saas] SAAS按包计费方式, 否则按次数计费方式
  --channel-path [android_app] 自动打渠道包，提供channel.txt文件路径 如./channel.txt
  --channel-name [android_app] AndroidManifest中自定义的渠道识别名，如UMENG_CHANNEL,CHANNEL

1. 例如使用saas服务加固一个Android的APP
appensys_cli.py --package-type=android_app --dx-saas --account=bob --password=bob --strategy-id=1000 -i in.apk -o protected.apk

2. 例如使用saas服务加固一个ios的APP
appensys_cli.py --package-type=ios_app --host-url=http://appen.dingxiang-inc.com --account=bob --password=bob --strategy-id=1000 -i in.zip -o protected.zip --xcode=6

3. 例如使用saas服务加固一个ios的APP，相对于例2, 额外在输出的文件中保留bitcode
appensys_cli.py --package-type=ios_app --host-url=http://appen.dingxiang-inc.com --account=bob --password=bob --strategy-id=1000 -i in.zip -o protected.zip --xcode=6 --keep-bitcode-in-output


"""
import threading
from io import BytesIO
import requests
import time
import os
import codecs
import traceback
import subprocess
from optparse import OptionParser

class AppGuardAPI:
    dgc_host_url = ""
    account = ""
    password = ""
    mutex = threading.Lock()
    # 單位秒
    timeout = 100
    token = ""
    ANDROID_APP = 1
    SAAS_URL = "http://appen.dingxiang-inc.com"



    def __init__(self, _url, _account, _passowrd):
        self.dgc_host_url = _url
        self.account = _account
        self.password = _passowrd
        self.__get_token()
        self.__process = None
        self.__isKill = False

    def __get_token(self):
        url = "{}/v1/authorize?userName={}&userPassword={}".format(
            self.dgc_host_url, self.account, self.password)
        try:
            response_json = self.__get_response(url, True).json()
        except Exception as inst:
            traceback.print_exc()
            return ""

        if response_json["success"] is True:
            self.token = response_json["data"]
            # print("Token: {}".format(self.token))
            return self.token
        else:
            return ""

    # 新建任務
    # return 0 if fail
    def __new_task(self, strategyId, file_path, params, retry=3):
        new_task_parameters = {}
        new_task_parameters["token"] = self.token
        task_name=os.path.basename(file_path)
        new_task_parameters["strategyInfoId"] = str(strategyId)
        new_task_parameters["name"] = task_name
        if ("packageType" in params):
            new_task_parameters["packageType"] = params["packageType"]
        if ("authType" in params):
            new_task_parameters["authType"] = params["authType"]
        #
        if ("entryClass" in params):
            new_task_parameters["entryClass"] = params["entryClass"]
        #
        if ("content" in params):
            new_task_parameters["content"] = params["content"]
        #
        if ("isBitCode" in params):
            new_task_parameters["isBitCode"] = params["isBitCode"]
        #
        if ("xcodeVersion" in params):
            new_task_parameters["xcodeVersion"] = params["xcodeVersion"]
        #
        #print (new_task_parameters)

        url = "{}/v1/task".format(self.dgc_host_url)
        # print url
        maxRetry = retry
        tryNow = 0

        while True:
            try:
                print ("post %s, task-name:%s url:%s param:%s"%(file_path, task_name, url, new_task_parameters))
                with open(file_path, 'rb') as f:
                    r = requests.post(url=url, data=new_task_parameters, files={'file': f})
                    if r.text == "":
                        print ("server invalid response [%s]"%r.text)
                        return -2
                    #
                    response = r.json()
                #
                print("resp:%s"%response)
                if response["success"]:
                    return response["data"]
                else:
                    if (tryNow >= maxRetry):
                        return 0
                    #
                    print ("new-task error return %r"%response)
                    tryNow += 1
                #
            #
            except requests.exceptions.ConnectionError as e:
                if (tryNow >= maxRetry):
                    raise
                    return -1
                #
                tryNow += 1
            #
        #

    #

    # 取得任务状态, 1:正在加固；0:加固完成；-1:加固失败
    def __get_task_status(self, task_id):
        if self.token_is_empty() is True:
            return -1
        url = "{}/v1/task/{}?token={}".format(self.dgc_host_url, task_id, self.token)

        cur_status = 0
        try:
            cur_status = self.__get_response(url, show_json_data=False).json()
        except Exception as inst:
            traceback.print_exc()
            return -1
        #
        # print cur_status
        if ("data" not in cur_status):
            print ("data not in resp server return %s"%cur_status)
            return "-1"
        #
        data_info = cur_status["data"]
        status = data_info["status"]

        return str(status)
    #

    # 取得保护后文件
    def __get_task_file(self, task_id, download_file_path):
        if self.token_is_empty() is True:
            return
        url = "{}/v1/task/file/{}?token={}&type={}&mode={}".format(self.dgc_host_url,
                                                                   task_id,
                                                                   self.token,
                                                                   "1",
                                                                   "1")
        print (url)
        try:
            response = self.__get_response(url, show_json_data=False)
        except Exception as inst:
            traceback.print_exc()
            return False

        rep_content = response.content
        if len(rep_content) < 200 and rep_content.find("success\":false"):
            print (rep_content)
            return False

        with open(download_file_path, 'wb') as f:
            for chunk in response.iter_content(chunk_size=1024):  # 邊下载邊儲存
                if chunk:
                    f.write(chunk)
                #
            #
            time.sleep(1)
        #
        return True

    def __get_response(self, url, show_json_data, retry=3):
        maxRetry = retry
        tryNow = 0
        timeout = self.timeout
        while True:
            try:
                # print("HTTP Requests URL: {}".format(url))
                response = requests.get(url=url, timeout=timeout, stream=True)
                if show_json_data:
                    print("HTTP Response JSON Data: {}".format(response.json()))
                return response
            except requests.exceptions.RequestException as e:
                if (tryNow>=maxRetry):
                    print ("exception after %d retry"%maxRetry)
                    raise
                    return
                #
                tryNow += 1
            #
        #
    #


    def token_is_empty(self):
        if self.token == "":
            print("token error")
            return True
        else:
            return False

    def doAppEnc(self, orig_path, out_path, strategyId, params={}):
        taskId = 0
        taskId = self.__new_task(strategyId, orig_path, params)
        print (taskId)
        print("taskId:%d, apk:%s"%(taskId, orig_path))
        if taskId <= 0:
            print("[-]upload %s fail, return invalid task id %d"%(orig_path, taskId))
            return False
        #
        print ("[+]upload " + orig_path + " ok")

        print(taskId)
        retry_times = 0
        prev_status = '-1'
        code2log = {"0":"waiting", "1":"protecting", "2":"protect ok"}
        while True:
            cur_status = str(self.__get_task_status(taskId))
            if (cur_status in code2log):
                if (cur_status != prev_status):
                    prev_status = cur_status
                    log = code2log[cur_status]
                    print ("[+]%s %s..."%(orig_path, log))
                    if (cur_status == '2'):
                        break
                    #
            else:
                if retry_times == 20:
                    print ("[-]protect "+orig_path+" fail, exit")
                    return False
                else:
                    print ("[-]protect %s return %s retry"%(orig_path, cur_status))
                retry_times = retry_times + 1
            #
            time.sleep(3)
            #
        #
        time.sleep(2)

        if not self.__get_task_file(taskId, out_path):
            print ("[-]Download "+out_path+" fail, exit")
            return False

        print("[+]"+out_path+" download ok")
        return True


# 这个入口用于测试api接口使用
# 需要request库,安装
# pip install requests -i https://pypi.tuna.tsinghua.edu.cn/simple
import sys
import job_runner


def __doChannel(in_apk, channel_path,channel_name):
    if(os.path.exists(in_apk) & os.path.exists(channel_path)):
        out_path = os.path.dirname(in_apk)
        channel_tool = "./android-appen-tools/mchannel.jar"
        __job = job_runner.JobRunner()
        print (channel_tool)
        if (os.path.exists(channel_tool)):
            if (channel_name is None or len(channel_name) == 0):
                channel_name = "UMENG_CHANNEL"
            print ("found channel tool...")
            cmd = "java -jar " + channel_tool + " -i " + in_apk + " -o " + out_path + " -f " + channel_path\
                  + " -n " + channel_name
            log_file = os.path.realpath('./channel.log')
            result = __job.run(cmd, open(log_file, "w"), subprocess.STDOUT, os.environ.copy())
            if(result == 0):
                print("auto making channel apk")
            else:
                print(result)
        else:
            print("channel_tool not found")
    else:
        print("Can`t find channel.txt or APK")


if __name__ == "__main__":

    description="顶象加固系统命令行，支持SAAS、私有化盒子"
    parser = OptionParser(usage="usage: %prog [options]", version='V20200415', description=description)
    parser.add_option("-i", "--input",          dest="input",  help="加固前文件（输入） *.apk/zip/aar/xcarchive")
    parser.add_option("-o", "--output",         dest="output", help="加固后文件保存位置（输出）")
    parser.add_option("--host-url",       dest="host_url", help="加固的服务端")
    parser.add_option("--dx-saas",        action="store_true", dest="dx_saas", help="等价于 --host-url=http://appen.dingxiang-inc.com", default=False)
    parser.add_option("-s", "--strategy-id",    dest="strategy_id", help="策略编号")
    parser.add_option("-t", "--package-type",    dest="package_type", help="文件类型：android_app, android_sdk, ios_app, ios_sdk, binary, android_scan")
    parser.add_option("-a", "--account",    dest="account", help="账户")
    parser.add_option("-p", "--password",    dest="password", help="密码")
    parser.add_option("--class-list-json",   dest="class_list_json", help="[android_sdk] 保护的类名列表，json格式")
    parser.add_option("--entry-class",      dest="entry_class", help="[android_sdk] 入口类名")
    parser.add_option("-b", "--keep-bitcode-in-output",    action="store_true",  dest="is_bitcode", help="[ios_app, ios_sdk] 加固后是否开启bitcode, 默认不保留", default=False)
    parser.add_option("--xcode",      dest="xcode", help="[ios_app, ios_sdk] 打包使用的Xcode版本，7: Xcode 12.0-12.1, 6: Xcode 11.4, 5: Xcode 11.0-11.3, 4: Xcode 10.2-10.3, 3: Xcode 10.0-10.1")
    parser.add_option("--saas-accounting-by-package", action="store_true", dest="saas_accounting_by_package", help="[saas] SAAS按包计费方式, 否则按次数计费方式", default=False)
    parser.add_option("--channel-path",  dest="channel_path", help="[android_app] 自动打渠道包，配置channel.txt的存储路径 ")
    parser.add_option("--channel-name",  dest="channel_name", help="[android_app] AndroidManifest中自定义的渠道识别名，如UMENG_CHANNEL,CHANNEL ")


    try:
        (options, args) = parser.parse_args()
    except UnicodeDecodeError:
        (pyVersion, _, _, _, _) = sys.version_info
        if pyVersion <= 2:
            print("py2 上无法打印 -h/--help, 请打开这个py文件，在文件头上有使用说明")
            sys.exit(-1)

    try:
        if options.help:
            parser.print_help()
    except AttributeError:
        pass

    if options.dx_saas:
        options.host_url='http://appen.dingxiang-inc.com'

    if options.host_url is None or options.input is None or options.output is None or options.account is None or options.password is None or options.package_type is None or options.strategy_id is None:
        print("ERROR: --host-url/--input/--output/--account/--password/--package-type/--strategy-id是必须的")
        sys.exit(-1)

    if options.package_type == 'ios_app' or options.package_type == 'ios_sdk':
        if options.xcode is None:
            print("ERROR: [ios_app/ios_app] --xcode必须指定， 您可以试试--xcode=6")
            sys.exit(-1)
    if options.package_type == 'android_sdk':
        if options.class_list_json is None:
            print("ERROR: [android_sdk] --class-list-json必须指定")
            sys.exit(-1)
        if options.entry_class is None:
            print("ERROR: [android_sdk] --entry-class必须指定")
            sys.exit(-1)
    if options.channel_path:
        if options.package_type != 'android_app':
            print("ERROR: [channel-path] 自动渠道只支持android app, --package-type请设为android_app")
            sys.exit(-1)

    strategyId = sys.argv[4]


    params = {}

    # FIXME legacy support, we will simplify the code to following in next release
    # params["packageType"] = packageType

    if options.host_url.find('appen.dingxiang-inc.com') > 0:
        # saas
        if options.package_type == "android_app":
            params["packageType"] = "1"
        elif options.package_type == "ios_app":
            params["packageType"] = "2"
        else:
            print("ERROR: SAAS版本不支持--package-type=" + options.package_type)
            sys.exit(-1)
        if options.saas_accounting_by_package:
            params["authType"] = "2"
        else:
            params["authType"] = "1"
        #
    else:
        # private
        if options.package_type == "android_app":
            params["packageType"] = "1"
        if options.package_type == "android_sdk":
            params["packageType"] = "2"
        elif options.package_type == "ios_app":
            params["packageType"] = "3"
        elif options.package_type == "ios_sdk":
            params["packageType"] = "4"
        elif options.package_type == "binary":
            params["packageType"] = "5"
        elif options.package_type == "android_scan":
            params["packageType"] = "6"
        #
    #
    # FIXME endof legacy support


    appGuard_object = AppGuardAPI(options.host_url, options.account, options.password)
    if (options.package_type == "android_sdk"):
        with codecs.open(options.class_list_json, 'r', encoding="utf-8") as f:
            params["content"] = f.read()
        #
        params["entryClass"] = options.entry_class
    #
    elif (options.package_type == "ios_app" or options.package_type == "ios_sdk"):
        if options.is_bitcode:
            params["isBitCode"] = '1'
        else:
            params["isBitCode"] = '0'
        params["xcodeVersion"] = options.xcode
    #

    in_file = options.input
    out_file = options.output
    print ("protecting %s..."%in_file)
    r = appGuard_object.doAppEnc(in_file, out_file, options.strategy_id, params)
    if (not r):
        print ("protect %s failed..."%in_file)
    else:
        print ("protect %s ok..."%in_file)

    if(options.channel_path):
        print ("start make channel...%s"%options.channel_path)

        __doChannel(out_file, options.channel_path,options.channel_name)

    #
#
