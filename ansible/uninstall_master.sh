#!/bin/bash

ansible-playbook \
--ssh-extra-args '-o StrictHostKeyChecking=no -o IdentitiesOnly=yes' \
-u ubuntu \
--private-key ../id_rsa \
-i "$(cat ../MASTER_IP)", ../playbooks/wait_for_connection.yml && \
ansible-playbook \
-e "UNINSTALL_K3S_SH=/usr/local/bin/k3s-uninstall.sh" \
--ssh-extra-args '-o StrictHostKeyChecking=no -o IdentitiesOnly=yes' \
-u ubuntu \
--private-key ../id_rsa \
-i "$(cat ../MASTER_IP)", ../playbooks/uninstall_k3s.yml