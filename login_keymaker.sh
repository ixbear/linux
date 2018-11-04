#!/bin/sh
spinaltap_user=zhang3
keymaker_user=zhang_san
host=$1
name=ec2-user
if [ ! -z $2 ]; then
  name=$2
fi
keypair=Simple-Q2-2016.key
if [ ! -z $3 ]; then
  keypair=$3
fi

ssh -o "ProxyCommand ssh -q -o StrictHostKeyChecking=no -A ${spinaltap_user}@spinaltap-prod.simple.io nc -w90 %h %p" ${keymaker_user}@keymaker.simple.com "cd /opt/keymaker/ && sudo -u keymaker -- fab -i /home/keymaker/.ssh/${keypair} -u ${name} -H ${host} ssh_grant"
#ssh -o "ProxyCommand ssh -q -o StrictHostKeyChecking=no -A ${spinaltap_user}@spinaltap-prod.simple.io nc -w90 %h %p" ${keymaker_user}@${host}
ssh ${keymaker_user}@${host}
