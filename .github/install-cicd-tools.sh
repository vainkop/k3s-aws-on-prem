#!/bin/bash -ex

export GREEN='\033[0;32m'
export YELLOW='\031[0;33m'
export RED='\033[0;31m'
export NC='\033[0m'

export AWS_ACCESS_KEY_ID="$1"
export AWS_SECRET_ACCESS_KEY="$2"
export ID_RSA="$3"
export TERRAFORM_VERSION="$4"
export KUBECTL_VERSION="$5"
export ANSIBLE_VERSION="$6"

export DEBIAN_FRONTEND=noninteractive

sudo apt-get update && \
sudo apt-get -y install \
apt-transport-https \
ca-certificates \
software-properties-common \
openssh-client \
wget \
unzip && \
wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
sudo unzip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin && \
sudo chmod +x /usr/local/bin/terraform && \
which terraform && \
terraform -v && \
wget https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
chmod +x kubectl && \
sudo mv kubectl /usr/local/bin/ && \
which kubectl && \
kubectl version --client && \
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt-get -y install ansible="$ANSIBLE_VERSION"

echo "$ID_RSA" | tr -d '\r' > id_rsa
chmod 400 id_rsa
eval "$(ssh-agent -s)"
ssh-add id_rsa

mkdir -p ~/.aws
echo "[default]" > ~/.aws/credentials
echo "aws_access_key_id = $AWS_ACCESS_KEY_ID" >> ~/.aws/credentials
echo "aws_secret_access_key = $AWS_SECRET_ACCESS_KEY" >> ~/.aws/credentials

printf "${GREEN}$(terraform -v) READY to use!\n${NC}"