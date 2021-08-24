#!/bin/bash -ex

export GREEN='\033[0;32m'
export NC='\033[0m'

export NODE_TYPE="$1" && \
printf "${GREEN}NODE_TYPE=$NODE_TYPE\n${NC}"

export IPS=$2 && \
printf "${GREEN}IPS=$IPS\n${NC}"

printf "${GREEN}Installing $NODE_TYPE...\n${NC}"

for IP in $IPS; do

  ansible-playbook \
  --ssh-extra-args '-o StrictHostKeyChecking=no -o IdentitiesOnly=yes' \
  -u ubuntu \
  --private-key ../id_rsa \
  -i "${IP}", wait_for_connection.yml && \
  ansible-playbook \
  --ssh-extra-args '-o StrictHostKeyChecking=no -o IdentitiesOnly=yes' \
  -u ubuntu \
  --private-key ../id_rsa \
  -i "${IP}", base.yml && \
  ansible-playbook \
  -e "INSTALL_K3S_VERSION=v1.21.4+k3s1" \
  -e "K3S_TOKEN=U88bSt5PrhJJZRCd" \
  -e "MASTER_IP=$(cat ../MASTER_IP)" \
  -e "NODE_ROLE=${NODE_TYPE}" \
  --ssh-extra-args '-o StrictHostKeyChecking=no -o IdentitiesOnly=yes' \
  -u ubuntu \
  --private-key ../id_rsa \
  -i "$IP", node.yml && \
  printf "${GREEN}Node $NODE_TYPE installed!\n${NC}"

done && \
sleep 20
