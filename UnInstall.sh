#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#Check Root
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

# Delete Files
rm -rf /etc/proxy-secret
rm -rf /etc/proxy-multi.conf
rm -rf /etc/secret
rm -rf /etc/proxy-port

# Delete service files
systemctl disable MTProxy.service
systemctl stop MTProxy
rm -rf /etc/systemd/system/MTProxy.service
systemctl daemon-reload


clear
echo "Successful uninstallation！"

rm -rf uninstall.sh
