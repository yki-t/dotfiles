#!/bin/zsh

if [ ${USER} = "root" ];then
    exit 1
fi

if [ ! "$(cat /etc/os-release|grep VERSION=|sed -e 's/VERSION=\"\(.*\)\"/\1/')" = "18.04.1 LTS (Bionic Beaver)" ];then
    exit 1
fi

sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common zsh vim git curl
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable test edge"
sudo apt update
sudo apt install -y docker-ce
docker -v

sudo gpasswd -a ${USER} docker
sudo chmod 666 /var/run/docker.sock
export compose='1.21.1'

sudo curl -L https://github.com/docker/compose/releases/download/${compose}/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod 0755 /usr/local/bin/docker-compose
docker-compose -v

