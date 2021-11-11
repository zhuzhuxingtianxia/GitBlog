##!/bin/sh

project_path=$(cd "$(dirname "$1")";pwd)

#echo "--------------------------------------------------------------------------------"
#echo "当前脚本所在文件目录： \n${project_path} "
#echo "--------------------------------------------------------------------------------"

target_file_path=$1

check_file_path(){
    arg=$1
    #echo "目标文件路径: \n$1"
    # 不是.a后缀静态库文件则退出
    if [ "${arg##*.}"x != "a"x ];then
        echo "\n目标文件非静态库.a文件\n"
        exit
    fi
}

if [[ $target_file_path ]]; then
    check_file_path $target_file_path
else
    echo "---------\n\n请输入静态库.a文件绝对路径或拖拽.a到终端\n\n---------"
    read target_file_path
    # 输入是否为空
    while [[ -z "$target_file_path" ]]; do
        #statements
        echo "---------\n\n请输入静态库.a文件绝对路径或拖拽.a到终端\n\n---------"
        read target_file_path
    done
fi
# 判断是否为.a静态库文件
while [ "${target_file_path##*.}"x != "a"x ];do
    echo "目标文件非静态库.a文件"
    read target_file_path
done

# 判断文件路径是否包含空格
#if [[ "$target_file_path" =~ ( |\') ]];then
#    echo "件路径包含空格,无法处理"
#    exit
#fi

# 定义数组
Deice_Archs=("arm64" "armv7" "i386" "x86_64")
# 获取数组的长度
# echo "Deice_Archs:${#Deice_Archs[*]}"

#1. 查看文件包含的架构,"$target_file_path"防止路径中包含空格
arch_info=`lipo -info "$target_file_path"`
#echo $arch_info

Target_Archs=()

for arch in $arch_info
do
    # 判断Deice_Archs数组是否包含arch，如果包含则添加到Target_Archs中
    if [[ ${Deice_Archs[@]/${arch}/} != ${Deice_Archs[@]} ]];then
        Target_Archs[${#Target_Archs[*]}]=${arch}
    fi
    
done

#echo ${Target_Archs[@]}

option=""
for ((i = 0; i < ${#Target_Archs[*]}; i++));do
    option+="$i:${Target_Archs[i]}  "
done

echo "--------------------------------------------------------------------------------"
echo "请选择架构 ? [ $option] "
echo "--------------------------------------------------------------------------------"

read archNumber
while (( $archNumber < 0 )) || (( $archNumber >= ${#Target_Archs[*]} )) ; do
    #statements
    echo "error!  \n输入值应大于等于0,小于${#Target_Archs[*]}"
    echo "请选择架构 ? [ $option] "
    read archNumber
done

#2. 根据选择分离出一种架构
arm_name=${Target_Archs[$archNumber]}
temp_sdk_path="${target_file_path%.a}_${arm_name}_temp"
reult_sdk_path="${target_file_path%.a}_${arm_name}"
echo "temp_sdk_path:${temp_sdk_path}"
temp_sdk_name=${temp_sdk_path##*/}.a
echo "temp_sdk_name:${temp_sdk_name}"

#移除文件
rm -rf "$temp_sdk_path" && mkdir "$temp_sdk_path"

lipo -thin $arm_name "$target_file_path" -output "$temp_sdk_path"/${temp_sdk_name}

echo "------------------------------分离架构成功-----------------------------------"

#3. 抽离.a文件中的.o文件
cd "$temp_sdk_path" && ar -x ${temp_sdk_name} && rm -rf ${temp_sdk_name}

echo "------------------------------抽离转化.o成功-----------------------------------"


##递归遍历
traverse_dir()
{
    filepath=$temp_sdk_path
    
    for file in `ls -a "$filepath"`
    do
        if [ -d "${filepath}"/$file ] ;then
            if [[ "$file" != '.' ]] && [[ "$file" != '..' ]] ;then
                #递归
                traverse_dir "${filepath}"/$file
            fi
        else
            #调用查找指定后缀文件
            check_suffix "${filepath}"/$file
        fi
    done
}

##获取后缀为.o的文件
check_suffix()
{
    file=$1
    
    if [ "${file##*.}"x = "o"x ];then
        file_name=${file##*/}
        m_file_name=${file_name%.*}.m
        echo $m_file_name
        nm "$file" > "$reult_sdk_path"/$m_file_name
        
    fi
}

# 创建输出结果文件
rm -rf "$reult_sdk_path" && mkdir "$reult_sdk_path"
# 调用函数
traverse_dir
# 清除临时文件
rm -rf "${temp_sdk_path}"

echo "===========.o文件转.m文件完成！！=========="
echo "输出文件到如下路径：\n$reult_sdk_path\n"
