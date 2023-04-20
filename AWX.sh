# This Script is for install AWX on Ubuntu 22.04 LTS AWX version 22.0.0 with kubernetes

# Upgrade and Update the system

sudo apt update && sudo apt upgrade -yq

# Install some packages
echo -n "Installing "

sudo apt install git -yq
echo -n "Git... "
sudo apt install make -yq
echo -n "Make... "
sudo apt install python3-pip -yq
echo -n "Python3-pip... "
sudo apt install curl -yq
echo -n "Curl... "

# Install Kubernetes (K3s)

curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644

# Install AWX Operator

cd ~
echo "Cloning AWX Operator... "
git clone https://github.com/ansible/awx-operator.git

cd awx-operator
echo "Installing AWX Operator... "
export NAMESPACE=awx
make deploy


cd ~
git clone https://github.com/kurokobo/awx-on-k3s.git
cd awx-on-k3s

AWX_HOST="awx.overtest.lan"

openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -out ./base/tls.crt -keyout ./base/tls.key -subj "/CN=${AWX_HOST}/O=${AWX_HOST}" -addext "subjectAltName = DNS:${AWX_HOST}"

# Create the AWX instance


cd ~/awx-on-k3s/base

sed -i 's/hostname: awx.example.com/hostname: awx.overtest.lan/g' awx.yaml

sed -i 's/- password=Ansible123!  / - password=jaime /g' kustomization.yaml


sudo mkdir -p /data/postgres-13
sudo mkdir -p /data/projects
sudo chmod 755 /data/postgres-13
sudo chown 1000:0 /data/projects

kubectl apply -k base

# Wait for the AWX instance to be ready

echo "Waiting for the AWX instance to be ready... "


