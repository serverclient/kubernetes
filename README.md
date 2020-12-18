# Introduction 
The installation process for kubernetes on Ubuntu.

# Getting Started
1.	Create VM on the same LAN and get the internal IP address.

2.	Run ubuntu-setup-env.sh with `sudo` **on each node**.

    `sudo ubuntu-setup-env.sh`

3.	Run ubuntu-first-node.sh **on the first node** with account `k8sadmin` which password is `Welc0me`

    `su - k8sadmin`

    `./ubuntu-first-node.sh`

4.	Make sure the security group(**port 80/443**) and the Domain name(need to be the same with **Host Name** you input above) has been setup properly.

5.  Connect to the rancher portal with browser and setup the portal password. (Notice that rancher need a while to finish the installation.)

# Adding nodes

1. Modify the rancher-cluster.yml on the first node.

    `vi ~/rke/rancher-cluster.yml`

2. run the following script to update the cluster.

    `~/rke/rke_linux-amd64 up --config ~/rke/rancher-cluster.yml`
