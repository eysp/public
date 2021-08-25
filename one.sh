#!/bin/bash

red='\033[0;31m'
plain='\033[0m'
#内网ip地址获取
ip=$(ifconfig | grep "inet addr" | awk '{ print $2}' | awk -F: '{print $2}' | awk 'NR==1')
if [[ ! -n "$ip" ]]; then
    ip="你的路由器IP"
fi
#默认安装目录/root
name=/root
#默认安装端口
nport=9999
clear
# check root
[[ $EUID -ne 0 ]] && echo -e "${red}错误: ${plain} 必须使用root用户运行此脚本！\n" && exit 1

echo -e "输入portainer汉化文件安装目录：${red} \n（必须是绝对路径如：/opt，不懂的直接回车，默认目录$name）\n"
read -p "输入目录名（留空默认：$name）: " webdir
echo -e "${plain}"
    if [[ ! -n "$webdir" ]]; then
        webdir=$name
    fi
read -p "输入服务端口（请避开已使用的端口）[留空默认$nport]: " port
    if [[ ! -n "$port" ]]; then
        port=$nport
    fi
if [[ ! -d "$webdir" ]] ; then
mkdir -p $webdir
cd $webdir
else
cd $webdir
fi
curl -sL https://github.com/eysp/public/archive/public.tar.gz | tar xz

rm -rf public

mv public-public public
    
docker stop portainer

docker rm portainer

docker rmi portainer/portainer:linux-arm64

docker rmi portainer/portainer-ce:linux-arm64

read -p "是否重置portainer账户密码[Y/n]" user
case $user in
    y) docker volume rm portainer_data;;
n) echo "不重置，你将使用之前安装的portainer账户密码登陆";;
*) echo "你输入的不是 y/n"
exit;;
esac
echo "现在开始安装Portainer"

docker pull portainer/portainer-ce:linux-arm64

docker run -d --restart=always --name="portainer" -p $port:9000 -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data -v $webdir/public:/public portainer/portainer-ce:linux-arm64


if [ "docker inspect --format '{{.State.Running}}' portainer" != "true" ]
then {
echo -e "portainer部署成功，${red}浏览器访问$ip:$port \c"
echo -e "${plain}"
}
else
{
    echo "抱歉，portainer安装失败，多运行几次脚本或者检查网络是否正常访问GitHub"
}
fi
