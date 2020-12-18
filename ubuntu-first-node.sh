#!/bin/bash
USERNAME=k8sadmin
PASSWORD=Welc0me
#IP=10.0.0.6
#RANCHER_HOSTNAME=kubernetes.bestproject.org

# read -p "Please enter your User Name: " USERNAME
# read -p "Please enter your Password: " PASSWORD
read -p "Please enter your Internal IP: " IP
read -p "Please enter your Host Name: " RANCHER_HOSTNAME

echo "### Generate ssh key ###"
rm -rf ~/.ssh
ssh-keygen -q -N '' -t rsa <<< ""$'\n'"y" 2>&1
ssh-keyscan -f ~/.ssh/id_rsa.pub ${IP} >> ~/.ssh/known_hosts

#sudo apt install sshpass
sshpass -p ${PASSWORD} ssh-copy-id ${USERNAME}@${IP}

echo "### Install rke ###"
mkdir ~/rke
wget https://github.com/rancher/rke/releases/download/v1.2.3/rke_linux-amd64 -P ~/rke/
chmod 700 ~/rke/rke_linux-amd64

echo "### Generate rancher-cluster.yml ###"
rm -rf ~/rke/rancher-cluster.yml
cat >>  ~/rke/rancher-cluster.yml << EOF
nodes:
  - address: ${IP}
    hostname_override: $HOSTNAME
    user: k8sadmin
    role: [controlplane,worker,etcd]
    labels:
      app: ingress
ingress:
  provider: nginx
  node_selector:
    app: ingress
  options:
    proxy-body-size: "1000m"
services:
  etcd:
    snapshot: true
    creation: 6h
    retention: 24h
dns:
    provider: coredns
EOF

cat ~/rke/rancher-cluster.yml

echo "### Install kubernetes with rke ###"
~/rke/rke_linux-amd64 up --config ~/rke/rancher-cluster.yml

echo "### Copy kube config ###"
mkdir ~/.kube
cp  ~/rke/kube_config_rancher-cluster.yml  ~/.kube/config
chmod 400 ~/.kube/config

echo "### Create cattle-system namespace ###"
kubectl create namespace cattle-system

echo "### Install rancher with Helm ###"
helm install rancher rancher-stable/rancher \
  --namespace cattle-system \
  --set hostname=${RANCHER_HOSTNAME} \
  --set ingress.tls.source=secret

#./kubectl -n cattle-system create secret tls tls-rancher-ingress \
#  --cert=ssl.crt \
#  --key=ssl.key