#!/usr/bin/env bash
### from wJc


# check file
if [[ ! -e /etc/os-release ]] ; then
	echo "ERROR: This system is not supported. Unable to get parameters!"
	exit
fi
source /etc/os-release
# check os
if [[ $ID != "centos" || $VERSION_ID -lt 7 ]] ; then
	echo "ERROR: Only systems above CentOS 7 are supported!"
	exit
fi

echo "INFO: This OS is $ID $VERSION_ID"
# check user
if [[ $USER != "root" ]] ; then
	echo "ERROR: Please execute on the root user!"
fi

# yum source acceleration
cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
sed -i "s/#baseurl/baseurl/g" /etc/yum.repos.d/CentOS-Base.repo
sed -i "s/mirrorlist=http/#mirrorlist=http/g" /etc/yum.repos.d/CentOS-Base.repo
sed -i "s@http://mirror.centos.org@https://repo.huaweicloud.com@g" /etc/yum.repos.d/CentOS-Base.repo
yum clean all
yum repolist all

# remove legacy
yum remove -y docker docker-client docker-client-latest docker-selinux docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine
yum remove -y docker-ce docker-ce-cli containerd.io
rm -rf /var/lib/docker

# install docker-ce
yum install -y yum-utils device-mapper-persistent-data lvm2 curl wget
yum-config-manager --add-repo https://repo.huaweicloud.com/docker-ce/linux/centos/docker-ce.repo
sudo sed -i 's+download.docker.com+repo.huaweicloud.com/docker-ce+' /etc/yum.repos.d/docker-ce.repo
yum makecache fast
yum install -y docker-ce docker-ce-cli containerd.io

# dockerhub acceleration
mkdir -p /etc/docker
tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://338ea64dbf7d416a910f84f265214185.mirror.swr.myhuaweicloud.com"]
}
EOF
systemctl daemon-reload
systemctl enable docker
systemctl restart docker

# install docker compose 
curl -L "https://mirror.ghproxy.com/https://github.com/docker/compose/releases/download/1.29.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# check docker-compose
if [[ `docker-compose -v` ]] ; then
	echo "ERROE: Docker compose installation failed!"
	exit
fi

# run
#docker-compose run

