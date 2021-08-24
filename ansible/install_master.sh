#!/bin/bash

export MASTER_IP="$(cat ../MASTER_IP)"

ansible-playbook \
--ssh-extra-args '-o StrictHostKeyChecking=no -o IdentitiesOnly=yes' \
-u ubuntu \
--private-key ../id_rsa \
-i "${MASTER_IP}", ../playbooks/wait_for_connection.yml && \
ansible-playbook \
--ssh-extra-args '-o StrictHostKeyChecking=no -o IdentitiesOnly=yes' \
-u ubuntu \
--private-key ../id_rsa \
-i "${MASTER_IP}", ../playbooks/base.yml && \
ansible-playbook \
-e "INSTALL_K3S_VERSION=v1.21.4+k3s1" \
-e "K3S_TOKEN=U88bSt5PrhJJZRCd" \
-e "MASTER_IP=${MASTER_IP}" \
--ssh-extra-args '-o StrictHostKeyChecking=no -o IdentitiesOnly=yes' \
-u ubuntu \
--private-key ../id_rsa \
-i "${MASTER_IP}", ../playbooks/master.yml