## Description

This script is used to scan users for all the ec2 instancs. and it's can be used to do some familar inventory for all the ec2 instances.

## Prepare ENV

1, install Python 2.7

2, install aws-cli command.

3, install aws-env tool.

## Get ip list from aws-cli

Enter the production ENV:
```
$(aws-env grindr-production) && echo $AWS_ACCESS_KEY_ID
```

list all the keys and how many ec2 instances are using these keys:
```
aws ec2 describe-instances --query "Reservations[*].Instances[*].[InstanceId,VpcId,KeyName,PublicIpAddress]" --output text | awk ' { print $3 } ' | sort | uniq -c
   1 Grindr-Devloper
 158 Grindr-Q2-2016
  45 Grindr-Q3-2015
   8 Grindr-VPC-EC2
   1 bigdata
  70 isre-shared
   6 isre-shared-v20180404
   1 keymaker.key.pub
   5 nominatim-prod
```

list all the private IPs which are using key Grindr-Q2-2016:
```
aws ec2 describe-instances --filters "Name=key-name, Values="Grindr-Q2-2016"" "Name=instance-state-name, Values="running"" --query Reservations[*].Instances[*].[InstanceId,KeyName,PrivateIpAddress] --outpu text | awk '{ print $3 }' | grep ^10  >  ip_list_Grindr-Q2-2016.txt
```

list all the private IPs which are using key Grindr-Q3-2015:
```
aws ec2 describe-instances --filters "Name=key-name, Values="Grindr-Q3-2015"" "Name=instance-state-name, Values="running"" --query Reservations[*].Instances[*].[InstanceId,KeyName,PrivateIpAddress] --outpu text | awk '{ print $3 }' | grep ^10  >  ip_list_Grindr-Q3-2015.txt
```

list all the private IPs which are using key isre-shared:
```
aws ec2 describe-instances --filters "Name=key-name, Values="isre-shared"" "Name=instance-state-name, Values="running"" --query Reservations[*].Instances[*].[InstanceId,KeyName,PrivateIpAddress] --outpu text | awk '{ print $3 }' | grep ^10  >  ip_list_isre-shared.txt
```

## Grant ssh permission and scan

grant ssh permission by kermaker for all the ec2 instances:
```
python grant_ssh_with_Grindr-Q3-2015_key.py -f ip_list_Grindr-Q3-2015.txt -u kun_zhu

python grant_ssh_with_Grindr-Q2-2016_key.py -f ip_list_Grindr-Q2-2016.txt -u kun_zhu
```

a little optimized work ( which can avoid to receive the prompt like yes/no when you first connect the instance ) :
```
for a in `cat ip_list_Grindr-Q2-2016.txt` ;do ssh-keyscan $a >> ~/.ssh/known_hosts; done    #避免弹出yes/no的提示
for a in `cat ip_list_Grindr-Q3-2015.txt` ;do ssh-keyscan $a >> ~/.ssh/known_hosts; done
```

use cmd.sh to scan/remove users for all the ec2 instances:
```
bash cmd.sh ip_list_Grindr-Q2-2016.txt
```

Note:

for these instances which use isre-shared key, DO NOT need to grant ssh-key by keymaker, because all the instances ( which use the isre-shared key ) are build by atlas, you can directly login these by using your private key.
```
vim cmd.sh    #uncomment the ssh kun@$dst_ip line, and replce the kun_zhu with your local username.

for a in `cat ip_list_isre-shared.txt` ;do ssh-keyscan $a >> ~/.ssh/known_hosts; done

bash cmd.sh ip_list_isre-shared.txt
```
