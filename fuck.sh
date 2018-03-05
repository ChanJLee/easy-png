# /bin/bash

argc=$#
argv=$@

function handle_help() {
    echo "命令格式: -d folder"
    echo "压缩folder下所有的文件"
    echo "\n"

    echo "命令格式: -i file"
    echo "需要被压缩的文件"
    echo "\n"

    echo "命令格式: -h"
    echo "帮助"
}

function do_compress() {
    image=$1
    tiny_response=`curl --user api:${TINY_KEY} --data-binary @${image} -i https://api.tinify.com/shrink`
    compressed_image_link=`echo ${tiny_response} | awk -F '"' '{print $(NF-1)}'`
    curl -o ${image} ${compressed_image_link}
}

function compress_image() {
    image=$1
    do_compress ${image}
}

function handle_compress_image() {
    if [[ ${argc} != 2 ]]; then
        echo "illegal argument"
        return -1
    fi

    image=`echo $argv | cut -d ' ' -f2`
    compress_image ${image}
}

function compress_folder() {
    folder=$1
    cd ${folder}
    images=`git status --porcelain | grep "^A" | cut -c 4-`
    for image in ${images}
    do
        if [[ ${image} == *.png ]]; then
            do_compress ${image}
        fi
    done
    cd -
}

function handle_compress_folder() {
    if [[ ${argc} != 2 ]]; then
        echo "illegal argument"
        return -1
    fi
    folder=`echo $argv | cut -d ' ' -f2`
    compress_folder ${folder}
}

function main() {

    if [[ ${TINY_KEY} == "" ]]; then
        echo "can not find tiny key"
        return -1
    fi

    if [[ ${argc} == 0 ]]; then
        return -1
    fi

    action_arg=`echo $argv | cut -d ' ' -f1`
    if [[ ${action_arg} == "-h" ]]; then
        handle_help
    elif [[ ${action_arg} == "-i" ]]; then
        handle_compress_image
    elif [[ ${action_arg} == "-d" ]]; then
        handle_compress_folder
    fi
}

main
