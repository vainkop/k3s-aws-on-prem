#!/bin/bash

export GREEN='\033[0;32m'
export NC='\033[0m'

export NODE_TYPE="$1"
export IPS=$2

echo -e "${GREEN}Uninstalling $NODE_TYPE...${NC}"

for IP in $IPS; do

  ansible-playbook \
  --ssh-extra-args '-o StrictHostKeyChecking=no -o IdentitiesOnly=yes' \
  -u ubuntu \
  --private-key ../id_rsa \
  -i "${IP}", ../playbooks/wait_for_connection.yml && \
  ansible-playbook \
  -e "UNINSTALL_K3S_SH=/usr/local/bin/k3s-agent-uninstall.sh" \
  --ssh-extra-args '-o StrictHostKeyChecking=no -o IdentitiesOnly=yes' \
  -u ubuntu \
  --private-key ../id_rsa \
  -i "$IP", ../playbooks/uninstall_k3s.yml

  export NODE_NAME=$(kubectl get nodes --no-headers -l=$NODE_TYPE=$NODE_TYPE | awk '{print $1}')

  if [ ! -z "$NODE_NAME" ]; then

    for NODE in $NODE_NAME; do
    
      kubectl delete node $NODE
    
      for PASSWORD in $(kubectl -n kube-system get secrets | grep node-password | awk '{print $1}' | grep $NODE); do

        kubectl -n kube-system delete secret $PASSWORD

      done

    done

  fi

done

kubectl get nodes --no-headers

echo -e "${GREEN}Done uninstalling $NODE_TYPE!${NC}"