#!/bin/bash -ex

export GREEN='\033[0;32m'
export YELLOW='\031[0;33m'
export RED='\033[0;31m'
export NC='\033[0m'

export ROOT_DIR="$PWD" && printf "${RED}ROOT_DIR=$ROOT_DIR\n${NC}"
export APPS_DIR="$ROOT_DIR/files/apps" && printf "${RED}APPS_DIR=$APPS_DIR\n${NC}"

export ANSIBLE="$ROOT_DIR/ansible" && printf "${RED}ANSIBLE=$ANSIBLE\n${NC}"

printf "${GREEN}Starting K3s AWS on-prem demo!\n${NC}"

rm -rf $ROOT_DIR/files/k3s_distrib/k3s-airgap-images-amd64.tar.gz MASTER_IP WORKER_IPS DB_IP ELK_IP k3s.yaml && \
wget -q -O $ROOT_DIR/files/k3s_distrib/k3s-airgap-images-amd64.tar.gz https://github.com/k3s-io/k3s/releases/download/v1.21.4%2Bk3s1/k3s-airgap-images-amd64.tar.gz && \
printf "${YELLOW}Terraforming...\n${NC}"
cd terraform && \
terraform init && \
terraform plan -input=false -out tfplan && \
terraform apply -input=false -auto-approve tfplan && \
printf "${GREEN}Infra ready!\n Starting Ansible playbooks...\n${NC}" && \
printf "${YELLOW}Setting node IPs...\n${NC}" && \
export WORKER_IPS="$(cat $ROOT_DIR/WORKER_IPS)" && printf "${RED}$WORKER_IPS\n${NC}" && \
export DB_IP="$(cat $ROOT_DIR/DB_IP)" && printf "${RED}$DB_IP\n${NC}" && \
export ELK_IP="$(cat $ROOT_DIR/ELK_IP)" && printf "${RED}$ELK_IP\n${NC}" && \
printf "${YELLOW}Starting Ansible playbooks...\n${NC}" && \
cd $ANSIBLE && \
chmod +x *.sh && \
export MASTER_IP="$(cat $ROOT_DIR/MASTER_IP)" && printf "${RED}MASTER_IP=$MASTER_IP${NC}\n" && \
./install_node.sh "master" "$(cat $ROOT_DIR/MASTER_IP)" && \
sed -i "s/127\.0\.0\.1/$MASTER_IP/g" $ROOT_DIR/k3s.yaml && \
mkdir -p ~/.kube && \
chmod 700 ~/.kube && \
cp $ROOT_DIR/k3s.yaml ~/.kube/config && \
chmod 600 ~/.kube/config && \
kubectl wait --for=condition=ready nodes -l=node-role.kubernetes.io/master=true --timeout=300s && \
printf "${GREEN}Master is UP!\n${NC}" && \
printf "${YELLOW}Checking Master pods...\n${NC}" && \
kubectl get pods --all-namespaces && \
printf "${YELLOW}Deploying Workers...\n${NC}" && \
cd $ANSIBLE && \
./install_node.sh "worker" "$WORKER_IPS"
./install_node.sh "db" "$DB_IP"
./install_node.sh "elk" "$ELK_IP"
printf "${GREEN}All workers deployed!\n${NC}" && \
kubectl wait --for=condition=ready nodes -l=kubernetes.io/arch=amd64 --timeout=300s && \
kubectl get nodes --no-headers --show-labels && \
printf "${YELLOW}Deploying Apps...\n${NC}" && \
cd $ROOT_DIR && \
./deploy.sh "$APPS_DIR" "prometheus" "monitoring"
./deploy.sh "$APPS_DIR" "elasticsearch" "elk"
./deploy.sh "$APPS_DIR" "kibana" "elk"
./deploy.sh "$APPS_DIR" "minio" "minio"
./deploy.sh "$APPS_DIR" "postgres" "postgres"
./deploy.sh "$APPS_DIR" "mongodb" "mongodb"
./deploy.sh "$APPS_DIR" "keydb" "keydb"
./deploy.sh "$APPS_DIR" "keycloak" "keycloak"
./deploy.sh "$APPS_DIR" "vault" "vault"
wait
printf "${GREEN}Apps deployed!\n${NC}"

printf "${GREEN}Configuring node roles (label)...\n${NC}"
for NODE_TYPE in worker db elk; do
  printf "$NODE_TYPE\n"
  export NODE_NAME=$(kubectl get nodes --no-headers -l="$NODE_TYPE"="$NODE_TYPE" | awk '{print $1}')
  printf "$NODE_NAME\n"
  for NODE in $NODE_NAME; do
    kubectl label node ${NODE} node-role.kubernetes.io/${NODE_TYPE}=${NODE_TYPE} --overwrite
  done
done && \
printf "${GREEN}All node roles (labels) were configured!\n${NC}"

printf "${GREEN}ALL Done!\n${NC}"
