#!/bin/bash

./install_node.sh "elk" "$(cat ../ELK_IP)" && \
sleep 30 && \
printf "${GREEN}ELK deployed!\n${NC}"