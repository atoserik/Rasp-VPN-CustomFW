#!/bin/bash

LogFile="/var/log/customfw.log"

custom_fw_start(){
	while read line; do
		$line
                if [ $? -eq 0 ]; then
			echo "Successfully added iptables rule: $line" >> $LogFile
		else
			echo "Error adding rule: $line" >> $LogFile
			exit 11
		fi
	done < /etc/iptables/iptables.rules
}

custom_fw_stop(){
	forward_rule_num=$(iptables -L FORWARD --line-numbers | grep anywhere | awk '{print $1}')
	echo "RetCode of forward_rule_num=$?" >> $LogFile
	postrouting_rule_num=$(iptables -t nat -L POSTROUTING --line-numbers | grep 39 | awk '{print $1}')
	echo "RetCode of postrouting_rule_nume=$?" >> $LogFile
	echo "Found the following rule numbers: FORWARD=$forward_rule_num, POSTROUTING=$postrouting_rule_num" >> $LogFile
	iptables -D FORWARD $forward_rule_num
	if [ $? -eq 0 ]; then
		echo "Succesfully deleted rule FORWARD" >> $LogFile
	else
		echo "ERROR deleting FORWARD rule" >> $LogFile
	fi
	iptables -t nat -D POSTROUTING $postrouting_rule_num
	if [ $? -eq 0 ]; then
		echo "Succesfully deleted rule POSTROUTING" >> $LogFile
	else
		echo "ERROR deleting POSTROUTING rule" >> $LogFile
	fi
}

ipforward_start(){
	sysctl net.ipv4.ip_forward=1
	if [ $? -eq 0 ]; then
		echo "Succesfully enabled net.ipv4.ip_forward" >> $LogFile
	else
		echo "ERROR enabling net.ipv4.ip_forward" >> $LogFile
	fi

}

ipforward_stop(){
	sysctl net.ipv4.ip_forward=0
	if [ $? -eq 0 ]; then
		echo "Succesfully disabled net.ipv4.ip_forward" >> $LogFile
	else
		echo "ERROR disabling net.ipv4.ip_forward" >> $LogFile
	fi	
}

############################

case "$1" in
	start)
		echo "---- Enabling conf ----" >> $LogFile
		echo "starting custom fw" >> $LogFile
		custom_fw_start
		echo "enabling ipforward" >> $LogFile
		ipforward_start
		;;
	stop)
		echo "---- Disabling firewall ----" >> $LogFile
		echo "stopping custom fw" >> $LogFile
		custom_fw_stop
		echo "disabling ipforward" >> $LogFile
		ipforward_stop
		;;
	restart)
		echo "---- Disabling firewall ----" >> $LogFile
		echo "stopping custom fw" >> $LogFile
		custom_fw_stop
		echo "disabling ipforward" >> $LogFile
		ipforward_stop
		echo "---- Enabling conf ----" >> $LogFile
		echo "starting custom fw" >> $LogFile
		custom_fw_start
		echo "enabling ipforward" >> $LogFile
		ipforward_start
		;;
esac
