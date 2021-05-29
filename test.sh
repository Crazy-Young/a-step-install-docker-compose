#!/usr/bin/env bash
### from wJc

YUM_URLS=( 
"https://mirrors.ustc.edu.cn/" 
"https://mirrors.163.com/" 
"https://mirrors.cloud.tencent.com/" 
"https://mirrors.huaweicloud.com/"  
)
APT_URLS=(
"https://mirrors.ustc.edu.cn/" 
"https://mirrors.163.com/" 
"https://mirrors.cloud.tencent.com/" 
"https://mirrors.huaweicloud.com/"  
)
DOCKER_CE_URLS=(
  "" 
)
DOCKER_HUB_URLS=(
  "" 
)
GITHUB_URLS=(
  "https://github.com/" 
  "https://github.com.cnpmjs.org/" 
  "https://github.wuyanzheshui.workers.dev/"
)
PIP_URLS=(
  ""
)

#curl -o /dev/null -L -s -w '%{time_connect}:%{time_pretransfer}:%{time_starttransfer}:%{time_total}\n' 'http://mirrors.163.com'

function getFastUrl() {
  # 
  local url_list=$*
  # 
  local time=10.0
  # 
  local url=""
  # 
  for item in ${url_list[*]} ; do
    # 
    local itime=`curl -o /dev/null -L -s -w '%{time_starttransfer}' $item`
    #echo $item "access time is:" $itime
    # 
    if [[ `expr $itime \> $time` -eq 0 ]]  ; then
      url=$item
      time=$itime
    fi
  done
  echo $url
}

url=$(GetFastUrl ${YUM_URLS[*]})
echo $url

