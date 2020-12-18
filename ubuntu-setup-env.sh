#!/bin/bash
USERNAME=k8sadmin
PASSWORD=Welc0me

#read -p "Please enter your User Name: " USERNAME
#read -p "Please enter your Password: " PASSWORD

echo "apt update/upgrade"
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y

echo "### Disable Firewalld ###"
sudo ufw disable

echo "### Add user k8sadmin ###"
useradd -s /bin/bash -d /home/${USERNAME}/ -m -G sudo ${USERNAME}
echo -e "$PASSWORD\n$PASSWORD" |passwd "$USERNAME"

echo "### Turn PasswordAuthentication to yes ###"
sudo sed -i "/^[^#]*PasswordAuthentication[[:space:]]no/c\PasswordAuthentication yes" /etc/ssh/sshd_config
sudo systemctl restart sshd

echo "### Install Docker ###"
sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install docker-ce=5:19.03.14~3-0~ubuntu-bionic docker-ce-cli=5:19.03.14~3-0~ubuntu-bionic containerd.io -y
sudo usermod -aG docker ${USERNAME}

echo "### Install sshpass ###"
sudo apt install sshpass

echo "### Install kubectl ###"
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.20.0/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
kubectl version --client

echo "### Install Helm and repo ###"
wget https://get.helm.sh/helm-v3.4.2-linux-amd64.tar.gz
tar -xzvf helm-v3.4.2-linux-amd64.tar.gz
mv linux-amd64/helm /usr/local/bin/helm
rm -rf helm-v3.4.2-linux-amd64.tar.gz
rm -rf linux-amd64
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
