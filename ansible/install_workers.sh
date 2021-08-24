#!/bin/bash

./install_node.sh "worker" "$(cat ../WORKER_IPS)" && \
sleep 30 && \
printf "${GREEN}Workers deployed!\n${NC}"