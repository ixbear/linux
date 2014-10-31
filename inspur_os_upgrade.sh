#!/bin/bash

dir=$(cd "$(dirname "$0")"; pwd)  #get the dirname of this script
time=`date +%Y.%m.%d-%H:%M:%S`

echo -e "\033[41;37m **************************************** \033[0m"
echo -e "\033[41;37m *                                      * \033[0m"
echo -e "\033[41;37m *    Inspur K-UX Upgrade Installer     * \033[0m"
echo -e "\033[41;37m *                                      * \033[0m"
echo -e "\033[41;37m *   For Inspur K-UX 1.2 ia64 Version   * \033[0m"
echo -e "\033[41;37m *                                      * \033[0m"
echo -e "\033[41;37m **************************************** \033[0m"
echo ""

cat /etc/inspur-release | grep -qI "2.1.3"
if [ $? -ne 0 ]; then
    echo "Your System is already K-UX 2.1.3. No need to Upgrade."
fi

for i in `ls $dir/2.1-2.1.3/*.rpm`
do
    rpm -Uvh $dir/$i --force
    echo "$time Upgraded: $i" >> /var/log/k-ux_update.log 
done

if [ -f /etc/redhat-release ]; then
    mv /etc/redhat-release /etc/inspur-release
fi
echo "Inspur K-UX release 2.1.3" > /etc/inspur-release
echo "Inspur K-UX release 2.1.3" > /etc/issue
echo "Inspur K-UX release 2.1.3" > /etc/issue.net

read -p "Upgrade complete. Please reboot to take effect. Reboot now? [y/n(default)]" reboot
if [ "$reboot" = "y" ] || [ "$reboot" = "Y" ]; then
    reboot
fi
