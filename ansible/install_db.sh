#!/bin/bash

./install_node.sh "db" "$(cat ../DB_IP)" && \
sleep 30 && \
printf "${GREEN}DB deployed!\n${NC}"