# K3s on AWS on-prem style AirGap mode !

Test your on prem K3s setup on AWS (AirGap mode).  
  
For convenience after a successfull deployment a `start` GitHub Action will create a GitHub issue with a link to your new `k3s.yaml`/`KUBECONFIG` file in your releases assets.  
  
Also a `stop` GitHub action will destroy all AWS infra + close all open GitHub issues with "New KUBECONFIG" topic .  
  
Tools used in this repo:
- Terraform
- Ansible
- kubectl
- helm

K8s apps deployed by this repo:
- Elasticsearch
- Kafka
- KeyCloak
- KeyDB
- Kibana
- Minio
- MongoDB
- PostgreSQL
- Prometheus
- Vault  

K8s apps are deployed not AirGap mode yet, but if you `docker save` + `docker load` then it is an AirGap mode.
  
This repo provisions a K3s cluster with `N=3` regular workers + 2 additional "tainted" workers for stateful loads like Postgres, Elasticsearch & etc
  
K3s is deployed in an AirGapped mode: docker images are uploaded by Ansible & docker loaded into it + some deb packages are uploaded & installed in a similar fashion.  
  
Do not forget to add proper GitHub secrets & Terraform variables!

GitHub secrets:
```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
ID_RSA
```
Terraform variables:
```
ssh_key_id
vpc_id
subnet_id
```
  

[If you have any questions/suggestions you can contact me directly in Telegram Here](https://t.me/vainkop)