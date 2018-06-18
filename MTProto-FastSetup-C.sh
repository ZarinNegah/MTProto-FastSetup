##################################################
# Anything wrong? Find me via telegram:@MTP_2018 #
##################################################

#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#Check Root
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

#Check OS
if [ -n "$(grep 'Aliyun Linux release' /etc/issue)" -o -e /etc/redhat-release ]; then
  OS=CentOS
  [ -n "$(grep ' 7\.' /etc/redhat-release)" ] && CentOS_RHEL_version=7
  [ -n "$(grep ' 6\.' /etc/redhat-release)" -o -n "$(grep 'Aliyun Linux release6 15' /etc/issue)" ] && CentOS_RHEL_version=6
  [ -n "$(grep ' 5\.' /etc/redhat-release)" -o -n "$(grep 'Aliyun Linux release5' /etc/issue)" ] && CentOS_RHEL_version=5
elif [ -n "$(grep 'Amazon Linux AMI release' /etc/issue)" -o -e /etc/system-release ]; then
  OS=CentOS
  CentOS_RHEL_version=6
else
  echo "${CFAILURE}Does not support this OS, Please contact the author! ${CEND}"
  kill -9 $$
fi

# Detect CPU Threads
THREAD=$(grep 'processor' /proc/cpuinfo | sort -u | wc -l)

# Define the Terminal Color
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

# Print Welcome Message
clear
echo "----------------------------------------------------"
echo "  Install MTProto For Telegram with Promoted Channel"
echo "  Author: ZarinNegah"
echo "  URL: http://Fastsetup.MTProtoServer.ir/"
echo "  Telegram: https://t.me/mtp_2018"
echo "----------------------------------------------------"
echo ""


if [ -f "/etc/secret" ]; then 
	IP=$(curl -4 -s ip.sb)
	SECRET=$(cat /etc/secret)
	PORT=$(cat /etc/proxy-port)
	TAG=$(cat /etc/proxy-tag)
	echo "MTProxy Installed！"
        echo "Server IP： ${IP}"
        echo "Port：      ${PORT}"
        echo "Secret：    ${SECRET}"
        echo "TAG：       ${TAG}"
        echo ""
        echo -e "TG Proxy link：${green}https://t.me/proxy?server=${IP}&port=${uport}&secret=${SECRET}${plain}"
        echo ""
        echo -e "TG Proxy link：${green}tg://proxy?server=${IP}&port=${uport}&secret=${SECRET}${plain}"
	echo ""
	exit 0
fi

# Firewalld
if [ ${OS} == CentOS ];then
  yum install firewalld -y
  systemctl enable firewalld
  systemctl start firewalld
  systemctl status firewalld
fi

# Enter the Proxy Port
read -p "Inout the Port for running MTProxy [Default: 2082]： " uport
if [[ -z "${uport}" ]];then
	uport="2082"
fi

if [ ${OS} == CentOS ];then
  yum update -y
  yum install wget gcc gcc-c++ flex bison make bind bind-libs bind-utils epel-release iptables-services openssl openssl-devel firewalld perl quota libaio libcom_err-devel libcurl-devel tar diffutils nano dbus.x86_64 db4-devel cyrus-sasl-devel perl-ExtUtils-Embed.x86_64 cpan vim-common screen libtool perl-core zlib-devel htop git curl sudo -y
  yum groupinstall "Development Tools" -y
fi

# Get Native IP Address
IP=$(curl -4 -s ip.sb)

# Switch to Temporary Directory
mkdir /tmp/MTProxy
cd /tmp/MTProxy

# Download MTProxy project source code
git clone https://github.com/TelegramMessenger/MTProxy

# Go to project compile and install to /usr/local/bin/
pushd MTProxy
make -j ${THREAD}
cp objs/bin/mtproto-proxy /usr/local/bin/

# Generate a Key
curl -s https://core.telegram.org/getProxySecret -o /etc/proxy-secret
curl -s https://core.telegram.org/getProxyConfig -o /etc/proxy-multi.conf
echo "${uport}" > /etc/proxy-port
head -c 16 /dev/urandom | xxd -ps > /etc/secret
SECRET=$(cat /etc/secret)
echo "Server IP： ${IP}"
echo "Port：      ${uport}"
echo "Secret：    ${SECRET}"
echo "Register your Proxy with Bot @MTProxybot on Telegram"
echo "Set received tag with @MTProxybot on Telegram and Past Command"
read -p "Set Proxy Tag： " proxytag
if [[ ${proxytag} = "" ]]; then
   proxytag=""
fi
echo "${proxytag}" > /etc/proxy-tag
TAG=$(cat /etc/proxy-tag)

# Set Up the Systemd Service Management Configuration
cat << EOF > /etc/systemd/system/MTProxy.service
[Unit]
Description=MTProxy
After=network.target

[Service]
Type=simple
WorkingDirectory=/usr/local/bin/
ExecStart=/usr/local/bin/mtproto-proxy -u nobody -p 64335 -H ${uport} -S ${SECRET} -P ${TAG} --aes-pwd /etc/proxy-secret /etc/proxy-multi.conf
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF


# Setting Up a Firewall
if [ ! -f "/etc/iptables.up.rules" ]; then 
    iptables-save > /etc/iptables.up.rules
fi

if [[ ${OS} == CentOS ]];then
	if [[ $CentOS_RHEL_version == 7 ]];then
		
        if [ $? -eq 0 ]; then
	        firewall-cmd --permanent --add-port=${uport}/tcp
		firewall-cmd --permanent --add-port=${uport}/udp
	        firewall-cmd --reload
	else
		iptables-restore < /etc/iptables.up.rules
		iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport $uport -j ACCEPT
    		iptables -I INPUT -m state --state NEW -m udp -p udp --dport $uport -j ACCEPT
		iptables-save > /etc/iptables.up.rules
		fi
	else
		iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport $uport -j ACCEPT
    	        iptables -I INPUT -m state --state NEW -m udp -p udp --dport $uport -j ACCEPT
		/etc/init.d/iptables save
		/etc/init.d/iptables restart
	fi
fi


# Set Boot From Start and Start MTProxy
systemctl daemon-reload
systemctl enable MTProxy.service
systemctl restart MTProxy

# Clean Installation Residue
rm -rf /tmp/MTProxy >> /dev/null 

# Display Service Information
clear
echo "MTProxy Successful Installation！"
echo "Server IP： ${IP}"
echo "Port：      ${uport}"
echo "Secret：    ${SECRET}"
echo "TAG：       ${TAG}"
echo ""
echo -e "TG Proxy link：${green}https://t.me/proxy?server=${IP}&port=${uport}&secret=${SECRET}${plain}"
echo ""
echo -e "TG Proxy link：${green}tg://proxy?server=${IP}&port=${uport}&secret=${SECRET}${plain}"
echo ""
