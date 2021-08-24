#!/bin/bash -xe

GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}Stopping...${NC}"

terraform init && \
terraform destroy -input=false -auto-approve && \
echo -e "${GREEN}Done!${NC}" && \
rm -rf .terraform* tfplan MASTER_IP WORKER_IPS DB_IP ELK_IP k3s.yaml