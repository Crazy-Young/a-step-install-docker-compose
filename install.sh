#!/usr/bin/env bash
### from wJc

SYS_ARCH=""
OS_NAME=""
OS_VER=""

YUM_URLS=( 
"https://mirrors.ustc.edu.cn" 
"https://mirrors.163.com" 
"https://mirrors.cloud.tencent.com" 
"https://repo.huaweicloud.com"  
)
APT_URLS=(
"https://mirrors.ustc.edu.cn" 
"https://mirrors.163.com" 
"https://mirrors.cloud.tencent.com" 
"https://repo.huaweicloud.com"  
)
DOCKER_CE_URLS=(
  "http://mirrors.ustc.edu.cn/docker-ce" 
  "https://mirrors.163.com/docker-ce"
  "https://mirrors.cloud.tencent.com/docker-ce"
  "https://repo.huaweicloud.com/docker-ce"
)
GITHUB_URLS=(
  "https://github.com" 
  "https://github.wuyanzheshui.workers.dev"
  "https://github.bajins.com"
  "https://github.rc1844.workers.dev"
#  "https://github.com.cnpmjs.org"
)
PIP_URLS=(
  "https://repo.huaweicloud.com/repository/pypi/simple"
  "https://mirrors.cloud.tencent.com/pypi/simple"
  "https://mirrors.163.com/pypi/simple/"
)
DOCKER_HUB_URLS=(
  "" 
)

# 检查系统是否具备最基本的要求.
function checkSys() {
    # check user
    if [[ `id -u` != "0" ]] ; then
        echo "ERROR: Please execute on the root user!"
        su
    fi

    # check file
    if [[ ! -e /etc/os-release ]] ; then
        echo "ERROR: This system is not supported. Unable to get parameters!"
        exit
    fi
    source /etc/os-release
    
    SYS_ARCH=`uname -m`
    OS_NAME=$ID
    OS_VER=$VERSION_ID


    case $SYS_ARCH in
        x86_64)
            case $OS_NAME in
                debian)
                    case $OS_VER in
                        10|11)
                            echo "this system is" $SYS_ARCH $OS_NAME $OS_VER
                        ;;
                        *)
                            echo $SYS_ARCH $OS_NAME $OS_VER "is not supported!"
                            exit
                        ;;
                    esac
                ;; 
                ubuntu)
                    case $OS_VER in
                        20.04|18.04)
                            echo "this system is" $SYS_ARCH $OS_NAME $OS_VER
                        ;;
                        *)
                            echo $SYS_ARCH $OS_NAME $OS_VER "is not supported!"
                            exit
                        ;;
                    esac
                ;;
                centos)
                    case $OS_VER in
                        7|8)
                            echo "this system is" $SYS_ARCH $OS_NAME $OS_VER
                        ;;
                        *)
                            echo $SYS_ARCH $OS_NAME $OS_VER "is not supported!"
                            exit
                        ;;
                    esac
                ;;
                *)
                    echo $SYS_ARCH $OS_NAME $OS_VER "is not supported!"
                    exit
                ;;
            esac
        ;;
        aarch64) 
            case $OS_NAME in
                debian)
                    case $OS_VER in
                        10|11)
                            echo "this system is" $SYS_ARCH $OS_NAME $OS_VER
                        ;;
                        *)
                            echo $SYS_ARCH $OS_NAME $OS_VER "is not supported!"
                            exit
                        ;;
                    esac
                ;;
                *)
                    echo $SYS_ARCH $OS_NAME $OS_VER "is not supported!"
                    exit
                ;;
            esac
        ;;
        *) 
            echo $SYS_ARCH $OS_NAME $OS_VER "is not supported!"
            exit
        ;;
    esac
    
}

# get fastest url
function getFastUrl() {
  # 把传入的url存入list
  local url_list=$*
  # 设置一个超时的临时值
  local time=10.0
  # 设置一个url空值
  local url=""
  # 开始遍历url
  for item in ${url_list[*]} ; do
    # 获取url的访问速度
    local itime=`curl --connect-timeout 2 -m 6 -o /dev/null -L -s -w '%{time_starttransfer}' $item`
    if [[ `expr ${itime:0:5} \!= 0.000` && `expr $itime \< $time` ]]  ; then
      # 判读这个访问速度是否是快的,如果是比超时的值快就存起来.
      url=$item
      time=$itime
    fi
  done
  echo $url
  # 通过下面的参数方法获取最快的url
  # url=$(getFastUrl ${GITHUB_URLS[*]})
}

# set pip source
function setPipMirror() {
    local url=$1
    echo "
[global]
index-url = $url
trusted-host = repo.huaweicloud.com
timeout = 120 " > ~/.pip/pip.conf
}

# set docker hub mirror
function setDockerHub() {
    # dockerhub acceleration
    local url=$1
    mkdir -p /etc/docker
    echo "{ \"registry-mirrors\": [\"$url\"] }"> /etc/docker/daemon.json
    systemctl daemon-reload
    systemctl enable docker
    systemctl restart docker
}

# run
function run(){
    # source acceleration
    case $OS_NAME in
        centos)
            local url=$(getFastUrl ${YUM_URLS[*]})
            sed -i "s/#baseurl/baseurl/g" /etc/yum.repos.d/CentOS-*.repo
            sed -i "s/mirrorlist=http/#mirrorlist=http/g" /etc/yum.repos.d/CentOS-*.repo
            sed -i "s@http://mirror.centos.org@$url@g" /etc/yum.repos.d/CentOS-*.repo
            yum clean all
            yum makecache
        ;;
        debian)
            apt update; apt install -y curl apt-transport-https ca-certificates;
            local url=$(getFastUrl ${APT_URLS[*]})
            cp -a /etc/apt/sources.list /etc/apt/sources.list.bak
            sed -i "s@http://ftp.debian.org@$url@g" /etc/apt/sources.list
            sed -i "s@http://security.debian.org@$url@g" /etc/apt/sources.list
            apt clean all
            apt update
        ;;
        ubuntu)
            apt update; apt install -y curl apt-transport-https ca-certificates;
            local url=$(getFastUrl ${APT_URLS[*]})
            cp -a /etc/apt/sources.list /etc/apt/sources.list.bak
            sed -i "s@http://.*archive.ubuntu.com@$url@g" /etc/apt/sources.list
            sed -i "s@http://.*security.ubuntu.com@$url@g" /etc/apt/sources.list
            apt clean all
            apt update
        ;;
        *)
            exit 
        ;;
    esac
    echo "set system mirror [Done]"

    # remove legacy
    case $OS_NAME in
        centos)
            yum remove -y docker docker-client docker-client-latest docker-selinux docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine
            yum remove -y docker-ce docker-ce-cli containerd.io
            rm -rf /var/lib/docker
        ;;
        debian|ubuntu)
            apt update; apt install -y curl;
            apt remove -y docker docker-engine docker.io containerd runc
            rm -rf /var/lib/docker
        ;;
        *)
            exit 
        ;;
    esac
    echo "remove legacy [Done]"
    
    # install docker-ce
    case $OS_NAME in
        centos)
            local url=$(getFastUrl ${DOCKER_CE_URLS[*]})
            yum install -y yum-utils device-mapper-persistent-data lvm2 curl wget
            yum-config-manager --add-repo $url/linux/centos/docker-ce.repo
            sed -i "s@https://download.docker.com@$url@g" /etc/yum.repos.d/docker-ce.repo
            yum makecache
            yum install -y docker-ce docker-ce-cli containerd.io
        ;;
        debian|ubuntu)
            apt install  -y apt-transport-https ca-certificates curl gnupg lsb-release
            local url=$(getFastUrl ${DOCKER_CE_URLS[*]})
            curl -fsSL $url/linux/$OS_NAME/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
            echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] $url/linux/$OS_NAME $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
            apt update
            apt install -y docker-ce docker-ce-cli containerd.io
        ;;
        *)
            exit 
        ;;
    esac
    echo "install docker-ce [Done]"

    # install docker compose
    local url=$(getFastUrl ${GITHUB_URLS[*]})
    echo "Github url: $url"
    if [[ `curl -o /dev/null -s -w '%{http_code}' -L "$url/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)"` -eq 200 ]] ; then
        curl -L "$url/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
    else
        local url=$(getFastUrl ${PIP_URLS[*]})
        apt install -y python python-pip
        pip install -i $url pip -U
        pip install docker-compose
    fi
    echo "install docker-compose [Done]"

}

# start install
function main(){
    checkSys
    run
    docker-compose version
}
main
# install done
