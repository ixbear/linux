#!/bin/bash
ip_list_file=$1

IP_LIST=`cat $ip_list_file`

$(aws-env grindr-production) && echo $AWS_ACCESS_KEY_ID
for dst_ip in ${IP_LIST[@]}; do
    echo -e "[ $dst_ip ]    \c"
    ssh kun_zhu@$dst_ip "awk -F'[/:]' '{if (\$3 >= 500 && \$3 != 65534) print \$1}' /etc/passwd | tr '\\n' '\\t '" 2>/dev/null
    #ssh -t kun_zhu@$dst_ip "for user in marko_miskovic mate_curkovic dorian_tahmas goran_juranic dario_pemper snezana_mamula marko_badurina marko_slipogor kevin_holly matija_merle sonja_deronja; do sudo userdel -r \$user; done" 2>/dev/null 
    #ssh kun@$dst_ip "awk -F'[/:]' '{if (\$3 >= 500 && \$3 != 65534) print \$1}' /etc/passwd | tr '\\n' '\\t '" 2>/dev/null
    #ssh kun@$dst_ip "pwd"
    echo ""
done
