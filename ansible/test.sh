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
-i "${MASTER_IP}", ../playbooks/base.yml