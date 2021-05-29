# a-step-install-docker-compose

## 介绍
这是一个docker 一键安装脚本.  
可以在linunx系统上一条命令部署docker-compose.

### 测试的版本如下
| 系统 |架构|版本| 镜像名 |软件包| 是否测试 |
|-|-|-|-|-|-|
|centos| x86_64|7 |CentOS-7-x86_64-Minimal-2009.iso |最小化|√|
|centos| x86_64|8 |CentOS-8.3.2011-x86_64-minimal.iso |最小化|√|
|centos| x86_64|8 |CentOS-Stream-8-x86_64-20210524-boot.iso |最小化|√|
|debian| x86_64|9 | ||×|
|debian| x86_64|10 | debian-live-10.9.0-amd64-standard.iso|默认|√|
|ubuntu|x86_64| 18.04 | ||×|
|ubuntu|x86_64| 20.04 | ubuntu-20.04.2-live-server-amd64.iso|默认|√|
|raspbian| arm64 | | ||×|


## 使用说明
此脚本均可一步运行.使用命令在下面.
ubuntu 可能会出现"Waiting for cache lock"问题.需要重启主机.

### centos或ubuntu 环境

``` curl -L https://gitee.com/Crazy-Young-xf/a-step-install-docker-compose/attach_files/716196/download/install.sh | bash ```


### debian或ubuntu 环境

``` wget https://gitee.com/Crazy-Young-xf/a-step-install-docker-compose/attach_files/716196/download/install.sh && bash install.sh ```

## 参与贡献
1.  Fork 本仓库
2.  新建 Feat_xxx 分支
3.  提交代码
4.  新建 Pull Request
