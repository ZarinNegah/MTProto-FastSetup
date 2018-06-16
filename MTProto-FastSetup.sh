##################################################
# Anything wrong? Find me via telegram: @MTP_2018 #
##################################################

#! /bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

function set_fonts_colors(){
# Font colors
default_fontcolor="\033[0m"
red_fontcolor="\033[31m"
green_fontcolor="\033[32m"
# Background colors
green_backgroundcolor="\033[42;37m"
# Fonts
error_font="${red_fontcolor}[Error]${default_fontcolor}"
ok_font="${green_fontcolor}[OK]${default_fontcolor}"
}

function check_os(){
	clear
	echo -e "Detecting if it is currently a ROOT user..."
	if [[ $EUID -ne 0 ]]; then
		clear
		echo -e "${error_font} is not currently a ROOT user. Please switch to the ROOT user before using this script."
		exit 1
	else
		clear
		echo -e "${ok_font} has detected that it is currently a Root user."
	fi
	clear
	echo -e "Detecting if this OS is supported..."
	if [ ! -z "$(cat /etc/issue | grep Debian)" ];then
		OS='debian'
		clear
		echo -e "${ok_font} This script supports your system."
	elif [ ! -z "$(cat /etc/issue | grep Ubuntu)" ];then
		OS='ubuntu'
		clear
		echo -e "${ok_font} This script supports your system."
	else
		clear
		echo -e "${error_font} does not currently support your operating system. Please switch to Debian/Ubuntu."
		exit 1
	fi
	clear
	echo -e "Detecting system architecture is supported..."
	system_bit=$(uname -m)
	if  [[ ${system_bit} = "x86_64" ]]; then
		clear
		echo -e "${ok_font} This script supports your system architecture."
	else
		clear
		echo -e "${error_font} does not currently support your system architecture. Please switch to x86_64."
		exit 1
	fi
	systemctl daemon-reload
	if [[ $? -eq 0 ]];then
		clear
		echo -e "${ok_font}The systemctl service is normal."
	else
		clear
		echo -e "${error_font}The systemctl service is not working properly and cannot be used!"
		exit 1
	fi
}

function check_install_status(){
	install_type=$(cat /usr/local/mtproto/install_type.txt)
	if [[ ${install_type} = "" ]]; then
		install_status="${red_fontcolor}Not installed${default_fontcolor}"
		mtproto_use_command="${red_fontcolor}Not Installed${default_fontcolor}"
	else
		install_status="${green_fontcolor}has been installed${default_fontcolor}"
		mtproto_use_command="${green_backgroundcolor}$(cat /usr/local/mtproto/telegram_link.txt)${default_fontcolor}"
	fi
	mtproto_program=$(find /usr/local/mtproto/mtproto)
	if [[ ${mtproto_program} = "" ]]; then
		mtproto_status="${red_fontcolor}Not Installed${default_fontcolor}"
	else
		mtproto_pid=$(ps -ef |grep "mtproto" |grep -v "grep" | grep -v ".sh"| grep -v "init.d" |grep -v "service" |awk '{print $2}')
		if [[ ${mtproto_pid} = "" ]]; then
			mtproto_status="${red_fontcolor}Not running${default_fontcolor}"
		else
			mtproto_status="${green_fontcolor}running${default_fontcolor} | ${green_fontcolor}${mtproto_pid}${default_fontcolor}"
		fi
	fi
}

function echo_install_list(){
	clear
	echo -e "The current installation status of the script：${install_status}
--------------------------------------------------------------------------------------------------
Install MTProto:
	1.MTProto Run Setup
--------------------------------------------------------------------------------------------------
MTProto Current Operating Status：${mtproto_status}
	2.Update Script
	3.Update Program
	4.Uninstall Program

	5.Starting Program
	6.Turn off an App
	7.Restart Program
--------------------------------------------------------------------------------------------------
Client run instructions：${mtproto_use_command}
--------------------------------------------------------------------------------------------------"
	stty erase '^H' && read -p "请输入序号：" determine_type
	if [[ ${determine_type} = "" ]]; then
		clear
		echo -e "${error_font}请输入序号！"
		exit 1
	elif [[ ${determine_type} -lt 0 ]]; then
		clear
		echo -e "${error_font}请输入正确的序号！"
		exit 1
	elif [[ ${determine_type} -gt 7 ]]; then
		clear
		echo -e "${error_font}请输入正确的序号！"
		exit 1
	else
		data_processing
	fi
}

function data_processing(){
	clear
	echo -e "正在处理请求中..."
	if [[ ${determine_type} = "0" ]]; then
		uninstall_old
	elif [[ ${determine_type} = "2" ]]; then
		upgrade_shell_script
	elif [[ ${determine_type} = "3" ]]; then
		prevent_uninstall_check
		upgrade_program
		restart_service
		clear
		echo -e "${ok_font}MTProto更新成功。"
	elif [[ ${determine_type} = "4" ]]; then
		prevent_uninstall_check
		uninstall_program
	elif [[ ${determine_type} = "5" ]]; then
		prevent_uninstall_check
		start_service
	elif [[ ${determine_type} = "6" ]]; then
		prevent_uninstall_check
		stop_service
	elif [[ ${determine_type} = "7" ]]; then
		prevent_uninstall_check
		restart_service
	else
		prevent_install_check
		os_update
		generate_base_config
		clear
		if [[ ${determine_type} = "1" ]]; then
			clear
			mkdir /usr/local/mtproto
			if [[ $? -eq 0 ]];then
				clear
				echo -e "${ok_font}建立文件夹成功。"
			else
				clear
				echo -e "${error_font}建立文件夹失败！"
				clear_install
				exit 1
			fi
			make_mtproto
			wget "https://core.telegram.org/getProxySecret" -O "/usr/local/mtproto/mtproto-secret"
			if [[ $? -eq 0 ]];then
				clear
				echo -e "${ok_font}下载配置文件成功。"
			else
				clear
				echo -e "${error_font}下载配置文件失败！"
				clear_install
				exit 1
			fi
			wget "https://core.telegram.org/getProxyConfig" -O "/usr/local/mtproto/mtproto-multi.conf"
			if [[ $? -eq 0 ]];then
				clear
				echo -e "${ok_font}下载配置文件成功。"
			else
				clear
				echo -e "${error_font}下载配置文件失败！"
				clear_install
				exit 1
			fi
			input_port
			head -c 16 /dev/urandom | xxd -ps > /usr/local/mtproto/secret
			if [[ $? -eq 0 ]];then
				clear
				echo -e "${ok_font}配置secret成功。"
			else
				clear
				echo -e "${error_font}配置secret失败！"
				clear_install
				exit 1
			fi
			clear
			echo -e "Host:Port | ${green_backgroundcolor}${Address}:${install_port}${default_fontcolor}"
			echo -e "Secret | ${green_backgroundcolor}$(cat /usr/local/mtproto/secret)${default_fontcolor}\n\n"
			stty erase '^H' && read -p "请输入Proxy Tag(可空)：" install_proxytag
			if [[ ${install_proxytag} = "" ]]; then
				install_proxytag=""
				echo -e "${install_proxytag}" > /usr/local/mtproto/install_proxytag.txt
				cat <<-EOF > /etc/systemd/system/mtproto.service
[Unit]
Description=mtproto
After=network.target
[Service]
ExecStart=/usr/local/mtproto/mtproto -u nobody -p 64335 -H $(cat /usr/local/mtproto/install_port.txt) -S $(cat /usr/local/mtproto/secret) --aes-pwd /usr/local/mtproto/mtproto-secret /usr/local/mtproto/mtproto-multi.conf
Restart=on-abort
[Install]
WantedBy=multi-user.target
				EOF
			else
				echo -e "${install_proxytag}" > /usr/local/mtproto/install_proxytag.txt
				cat <<-EOF > /etc/systemd/system/mtproto.service
[Unit]
Description=mtproto
After=network.target
[Service]
ExecStart=/usr/local/mtproto/mtproto -u nobody -p 64335 -H $(cat /usr/local/mtproto/install_port.txt) -S $(cat /usr/local/mtproto/secret) --aes-pwd /usr/local/mtproto/mtproto-secret /usr/local/mtproto/mtproto-multi.conf -P ${install_proxytag}
Restart=on-abort
[Install]
WantedBy=multi-user.target
				EOF
			fi
			if [[ $? -eq 0 ]];then
				clear
				echo -e "${ok_font}配置mtproto_service成功。"
			else
				clear
				echo -e "${error_font}配置mtproto_service失败！"
				clear_install
				exit 1
			fi
			systemctl enable mtproto.service
			if [[ $? -eq 0 ]];then
				clear
				echo -e "${ok_font}设置开启自启动成功。"
			else
				clear
				echo -e "${error_font}设置开启自启动失败！"
				clear_install
				exit 1
			fi
			echo "1" > /usr/local/mtproto/install_type.txt
			if [[ $? -eq 0 ]];then
				clear
				echo -e "${ok_font}写入安装信息成功。"
			else
				clear
				echo -e "${error_font}写入安装信息失败！"
				clear_install
				exit 1
			fi
			restart_service
			echo_mtproto_config
		fi
	fi
	echo -e "\n${ok_font}请求处理完毕。"
}

function make_mtproto(){
	clear
	echo -e "安装MTProto主程序中..."
	mkdir /tmp/make_mtproto
	if [[ $? -eq 0 ]];then
		clear
		echo -e "${ok_font}创建临时文件夹成功。"
	else
		clear
		echo -e "${error_font}创建临时文件夹失败！"
		clear_install
		exit 1
	fi
	cd /tmp/make_mtproto
	if [[ $? -eq 0 ]];then
		clear
		echo -e "${ok_font}进入临时文件夹成功。"
	else
		clear
		echo -e "${error_font}进入临时文件夹失败！"
		clear_install
		exit 1
	fi
	git clone https://github.com/TelegramMessenger/MTProxy
	if [[ $? -eq 0 ]];then
		clear
		echo -e "${ok_font}克隆MTProto成功。"
	else
		clear
		echo -e "${error_font}克隆MTProto失败！"
		clear_install
		exit 1
	fi
	pushd MTProxy
	if [[ $? -eq 0 ]];then
		clear
		echo -e "${ok_font}推送MTProto成功。"
	else
		clear
		echo -e "${error_font}推送MTProto失败！"
		clear_install
		exit 1
	fi
	make -j ${cpu_core}
	if [[ $? -eq 0 ]];then
		clear
		echo -e "${ok_font}编译MTProto成功。"
	else
		clear
		echo -e "${error_font}编译MTProto失败！"
		clear_install
		exit 1
	fi
	cp objs/bin/mtproto-proxy /usr/local/mtproto/mtproto
	if [[ $? -eq 0 ]];then
		clear
		echo -e "${ok_font}复制MTProto成功。"
	else
		clear
		echo -e "${error_font}复制MTProto失败！"
		clear_install
		exit 1
	fi
	chmod +x /usr/local/mtproto/mtproto
	if [[ $? -eq 0 ]];then
		clear
		echo -e "${ok_font}MTProto权限设置成功。"
	else
		clear
		echo -e "${error_font}MTProto权限设置失败！"
		clear_install
		exit 1
	fi
	cd /root
	if [[ $? -eq 0 ]];then
		clear
		echo -e "${ok_font}返回root文件夹成功。"
	else
		clear
		echo -e "${error_font}返回root文件夹失败！"
		clear_install
		exit 1
	fi
	rm -rf /tmp/make_mtproto
	if [[ $? -eq 0 ]];then
		clear
		echo -e "${ok_font}删除临时文件夹成功。"
	else
		clear
		echo -e "${error_font}删除临时文件夹失败！"
		clear_install
		exit 1
	fi
	clear
	echo -e "${ok_font}MTProto下载成功。"
}

function upgrade_shell_script(){
	clear
	echo -e "正在更新脚本中..."
	filepath=$(cd "$(dirname "$0")"; pwd)
	filename=$(echo -e "${filepath}"|awk -F "$0" '{print $1}')
	curl -O https://raw.githubusercontent.com/1715173329/mtproto-onekey/master/mtproto-go.sh
	if [[ $? -eq 0 ]];then
		clear
		echo -e "${ok_font}脚本更新成功，脚本位置：\"${green_backgroundcolor}${filename}/mtproto-go.sh${default_fontcolor}\"，使用：\"${green_backgroundcolor}bash ${filename}/mtproto-go.sh${default_fontcolor}\"。"
	else
		clear
		echo -e "${error_font}脚本更新失败！"
	fi
}

function prevent_uninstall_check(){
	clear
	echo -e "正在检查安装状态中..."
	install_type=$(cat /usr/local/mtproto/install_type.txt)
	if [ "${install_type}" = "" ]; then
		clear
		echo -e "${error_font}您未安装本程序。"
		exit 1
	else
		echo -e "${ok_font}您已安装本程序，正在执行相关命令中..."
	fi
}

function start_service(){
	clear
	echo -e "正在启动服务中..."
	install_type=$(cat /usr/local/mtproto/install_type.txt)
	if [ "${install_type}" -eq "1" ]; then
		if [[ ${mtproto_pid} -eq 0 ]]; then
			service mtproto start
			if [[ $? -eq 0 ]];then
				clear
				echo -e "${ok_font}MTProto 启动成功。"
			else
				clear
				echo -e "${error_font}MTProto 启动失败！"
			fi
		else
			clear
			echo -e "${error_font}MTProto 正在运行。"
		fi
	fi
}

function stop_service(){
	clear
	echo -e "正在停止服务中..."
	install_type=$(cat /usr/local/mtproto/install_type.txt)
	if [ "${install_type}" -eq "1" ]; then
		if [[ ${mtproto_pid} -eq 0 ]]; then
			clear
			echo -e "${error_font}MTProto 未在运行。"
		else
			service mtproto stop
			if [[ $? -eq 0 ]];then
				clear
				echo -e "${ok_font}MTProto 停止成功。"
			else
				clear
				echo -e "${error_font}MTProto 停止失败！"
			fi
		fi
	fi
}

function restart_service(){
	clear
	echo -e "正在重启服务中..."
	install_type=$(cat /usr/local/mtproto/install_type.txt)
	if [ "${install_type}" -eq "1" ]; then
		service mtproto restart
		if [[ $? -eq 0 ]];then
			clear
			echo -e "${ok_font}MTProto 重启成功。"
		else
			clear
			echo -e "${error_font}MTProto 重启失败！"
		fi
	fi
}

function prevent_install_check(){
	clear
	echo -e "正在检测安装状态中..."
	if [[ ${determine_type} = "1" ]]; then
		if [[ ${install_status} = "${green_fontcolor}已安装${default_fontcolor}" ]]; then
			echo -e "${error_font}您已经安装MTProto，请勿再次安装；如您需要重新安装，请先卸载后再使用安装功能。"
			exit 1
		else
			if [[ ${mtproto_status} = "${red_fontcolor}未安装${default_fontcolor}" ]]; then
				echo -e "${ok_font}系统检测到您的VPS上未安装MTProto，正在执行命令中..."
			else
				echo -e "${error_font}您的VPS上已经安装MTProto，请勿再次安装，若您需要使用本脚本，请先卸载后再使用安装功能。"
				exit 1
			fi
		fi
	fi
}

function uninstall_program(){
	clear
	echo -e "正在卸载中..."
	install_type=$(cat /usr/local/mtproto/install_type.txt)
	if [[ "${install_type}" -eq "1" ]]; then
		service mtproto stop
		systemctl disable mtproto.service
		rm -rf /etc/systemd/system/mtproto.service
		rm -rf /usr/local/mtproto
		if [[ $? -eq 0 ]];then
			clear
			echo -e "${ok_font}MTProto卸载成功。"
		else
			clear
			echo -e "${error_font}MTProto卸载失败！"
		fi
	fi
}

function upgrade_program(){
	clear
	echo -e "正在更新程序中..."
	install_type=$(cat /usr/local/mtproto/install_type.txt)
	if [ "${install_type}" -eq "1" ]; then
		clear
		mv /usr/local/mtproto/mtproto /usr/local/mtproto/mtproto.bak
		if [[ $? -eq 0 ]];then
			clear
			echo -e "${ok_font}备份旧文件成功。"
		else
			clear
			echo -e "${error_font}备份旧文件失败！"
			exit 1
		fi
		echo -e "更新MTProto主程序中..."
		clear
		generate_base_config
		clear
		mkdir /tmp/make_mtproto
		if [[ $? -eq 0 ]];then
			clear
			echo -e "${ok_font}创建临时文件夹成功。"
		else
			clear
			echo -e "${error_font}创建临时文件夹失败！"
			recovery_update
			exit 1
		fi
		cd /tmp/make_mtproto
		if [[ $? -eq 0 ]];then
			clear
			echo -e "${ok_font}进入临时文件夹成功。"
		else
			clear
			echo -e "${error_font}进入临时文件夹失败！"
			recovery_update
			exit 1
		fi
		git clone https://github.com/TelegramMessenger/MTProxy
		if [[ $? -eq 0 ]];then
			clear
			echo -e "${ok_font}克隆MTProto成功。"
		else
			clear
			echo -e "${error_font}克隆MTProto失败！"
			recovery_update
			exit 1
		fi
		pushd MTProxy
		if [[ $? -eq 0 ]];then
			clear
			echo -e "${ok_font}推送MTProto成功。"
		else
			clear
			echo -e "${error_font}推送MTProto失败！"
			recovery_update
			exit 1
		fi
		make -j ${cpu_core}
		if [[ $? -eq 0 ]];then
			clear
			echo -e "${ok_font}编译MTProto成功。"
		else
			clear
			echo -e "${error_font}编译MTProto失败！"
			recovery_update
			exit 1
		fi
		cp objs/bin/mtproto-proxy /usr/local/mtproto/mtproto
		if [[ $? -eq 0 ]];then
			clear
			echo -e "${ok_font}复制MTProto成功。"
		else
			clear
			echo -e "${error_font}复制MTProto失败！"
			recovery_update
			exit 1
		fi
		chmod +x /usr/local/mtproto/mtproto
		if [[ $? -eq 0 ]];then
			clear
			echo -e "${ok_font}MTProto权限设置成功。"
		else
			clear
			echo -e "${error_font}MTProto权限设置失败！"
			recovery_update
			exit 1
		fi
		cd /root
		if [[ $? -eq 0 ]];then
			clear
			echo -e "${ok_font}返回root文件夹成功。"
		else
			clear
			echo -e "${error_font}返回root文件夹失败！"
			recovery_update
			exit 1
		fi
		rm -rf /tmp/make_mtproto
		if [[ $? -eq 0 ]];then
			clear
			echo -e "${ok_font}删除临时文件夹成功。"
		else
			clear
			echo -e "${error_font}删除临时文件夹失败！"
			recovery_update
			exit 1
		fi
		clear
		rm -rf /usr/local/mtproto/mtproto.bak
		if [[ $? -eq 0 ]];then
			clear
			echo -e "${ok_font}删除备份文件成功。"
		else
			clear
			echo -e "${error_font}删除备份文件失败！"
		fi
		clear
		echo -e "${ok_font}MTProto更新成功。"
	fi
}

function recovery_update(){
	mv /usr/local/mtproto/mtproto.bak /usr/local/mtproto/mtproto
	if [[ $? -eq 0 ]];then
		clear
		restart_service
		clear
		echo -e "${ok_font}恢复备份文件成功。"
	else
		clear
		echo -e "${error_font}恢复备份文件失败！"
		exit 1
	fi
}

function clear_install(){
	clear
	echo -e "正在卸载中..."
	if [ "${determine_type}" -eq "1" ]; then
		rm -rf /tmp/make_mtproto
		service mtproto stop
		systemctl disable mtproto.service
		rm -rf /etc/systemd/system/mtproto.service
		rm -rf /usr/local/mtproto
		if [[ $? -eq 0 ]];then
			clear
			echo -e "${ok_font}MTProto卸载成功。"
		else
			clear
			echo -e "${error_font}MTProto卸载失败！"
		fi
	fi
}

function os_update(){
	clear
	echo -e "正在安装/更新系统组件中..."
	clear
	apt-get -y update
	apt-get -y upgrade
	apt-get -y install wget curl make unzip lsof cron iptables git build-essential libssl-dev zlib1g-dev
	if [[ $? -ne 0 ]];then
		clear
		echo -e "${error_font}系统组件更新失败！"
		exit 1
	else
		clear
		echo -e "${ok_font}系统组件更新成功。"
	fi
}

function generate_base_config(){
	clear
	echo "正在生成基础信息中..."
	Address=$(curl https://ipinfo.io/ip)
	cpu_core=$(grep 'processor' /proc/cpuinfo | sort -u | wc -l)
	if [[ ${Address} = "" ]]; then
		clear
		echo -e "${error_font}读取vps_ip失败！"
		clear_install
		exit 1
	else
		clear
		echo -e "${ok_font}您的vps_ip为：${Address}"
	fi
	if [[ ${cpu_core} = "" ]]; then
		clear
		echo -e "${error_font}读取CPU核心数失败！"
		clear_install
		exit 1
	else
		clear
		echo -e "${ok_font}您的CPU核心数为：${cpu_core}"
	fi
}

function input_port(){
	clear
	stty erase '^H' && read -p "请输入监听端口(默认监听1080端口)：" install_port
	if [[ ${install_port} = "" ]]; then
		install_port="1080"
	fi
	check_port
	echo -e "${install_port}" > "/usr/local/mtproto/install_port.txt"
	if [[ $? -eq 0 ]];then
		clear
		echo -e "${ok_font}mtproto端口配置成功。"
	else
		clear
		echo -e "${error_font}mtproto端口配置失败！"
		clear_install
		exit 1
	fi
}

function check_port(){
	clear
	echo "正在检查端口占用情况："
	if [[ 0 -eq $(lsof -i:"${install_port}" | wc -l) ]];then
		clear
		echo -e "${ok_font}端口未被占用。"
		open_port
	else
		clear
		echo -e "${error_font}端口被占用，请切换使用其他端口。"
		clear_install
		exit 1
	fi
}

function open_port(){
	clear
	echo -e "正在设置防火墙中..."
	iptables-save > /etc/iptables.up.rules
	echo -e '#!/bin/bash\n/sbin/iptables-restore < /etc/iptables.up.rules' > /etc/network/if-pre-up.d/iptables
	chmod +x /etc/network/if-pre-up.d/iptables
	iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport ${install_port} -j ACCEPT
	iptables -I INPUT -m state --state NEW -m udp -p udp --dport ${install_port} -j ACCEPT
	iptables-save > /etc/iptables.up.rules
	if [[ $? -eq 0 ]];then
		clear
		echo -e "${ok_font}端口开放配置成功。"
	else
		clear
		echo -e "${error_font}端口开放配置失败！"
		clear_install
		exit 1
	fi
}

function echo_mtproto_config(){
	if [[ ${determine_type} = "1" ]]; then
		clear
		telegram_link="https://t.me/proxy?server=${Address}&port=${install_port}&secret=$(cat /usr/local/mtproto/secret)" 
		echo -e "您的连接信息如下："
		echo -e "服务器地址：${Address}"
		echo -e "端口：${install_port}"
		echo -e "Secret：$(cat /usr/local/mtproto/secret)"
		echo -e "Telegram设置指令：${green_backgroundcolor}${telegram_link}${default_fontcolor}"
	fi
	echo -e "${telegram_link}" > /usr/local/mtproto/telegram_link.txt
}

function main(){
	set_fonts_colors
	check_os
	check_install_status
	echo_install_list
}

	main
