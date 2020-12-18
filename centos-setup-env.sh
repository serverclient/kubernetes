#!/bin/bash
echo "yum upgrade"
sudo yum upgrade -y

echo "Disable SELinux"
sudo setenforce 0
sudo sed -i s/^SELINUX=.*$/SELINUX=disabled/ /etc/selinux/config

echo "Disable Firewalld"
sudo systemctl stop firewalld
sudo systemctl disable firewalld

echo "Add user k8sadmin"
sudo useradd k8sadmin
echo 'Welc0me' | passwd k8sadmin --stdin
sudo usermod -aG wheel k8sadmin

echo "Turn PasswordAuthentication to yes"
sudo sed -i "/^[^#]*PasswordAuthentication[[:space:]]no/c\PasswordAuthentication yes" /etc/ssh/sshd_config
sudo systemctl restart sshd

echo "Install Docker"
sudo yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce-19.03.14 docker-ce-cli-19.03.14 containerd.io -y
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl enable docker

usermod -aG docker k8sadmin
