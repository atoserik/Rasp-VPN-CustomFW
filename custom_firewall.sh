#!/bin/bash

LogFile="/var/log/customfw.log"

LogMessage(){
	echo "$(date "+%F %T") - $1 - $2" >> $LogFile
}


custom_fw_start(){
	while read line; do
		$line
		RetCode=$?
                if [ $RetCode -eq 0 ]; then
			LogMessage "INFO" "Successfully added iptables rule: $line" 
		else
			LogMessage "ERROR" "Adding rule: $line - RetCode: $RetCode" 
			exit 11
		fi
	done < /etc/iptables/iptables.rules
}

custom_fw_stop(){
	forward_rule_num=$(iptables -L FORWARD --line-numbers | grep anywhere | awk '{print $1}')
	RetCode=$?
	if [ $RetCode -eq 0 ]; then
		LogMessage "INFO" "Found forward rule with priority: $forward_rule_number"
		iptables -D FORWARD $forward_rule_num
		RetCode=$?
		if [ $RetCode -eq 0 ]; then
			LogMessage "INFO" "Succesfully deleted forward rule"
		else
			LogMessage "ERROR" "Deleting forward rule. RetCode: $RetCode"
		fi
	else
		LogMessage "ERROR" "Getting the number of the forward rule. RetCode: $RetCode"
	fi	
	postrouting_rule_num=$(iptables -t nat -L POSTROUTING --line-numbers | grep 39 | awk '{print $1}')
	RetCode=$?
	if [ $RetCode -eq 0 ]; then
		LogMessage "INFO" "Found postrouting rule with priority: $postrouting_rule_num"
		iptables -t nat -D POSTROUTING $postrouting_rule_num
		RetCode=$?
		if [ $RetCode -eq 0 ]; then
			LogMessage "INFO" "Succesfully deleted postrouting rule"
		else
			LogMessage "ERROR" "Deleting postrouting rule. RetCode: $RetCode"
		fi
	else
		LogMessage "ERROR" "Getting the number of the forward rule. RetCode: $RetCode"
	fi

}

ipforward_start(){
	sysctl net.ipv4.ip_forward=1
	RetCode=$?
	if [ $RetCode -eq 0 ]; then
		LogMessage "INFO" "Succesfully enabled net.ipv4.ip_forward" 
	else
		LogMessage "ERROR" "Enabling net.ipv4.ip_forward. RetCode: $RetCode" 
	fi

}

ipforward_stop(){
	sysctl net.ipv4.ip_forward=0
	RetCode=$?
	if [ $RetCode -eq 0 ]; then
		LogMessage "INFO" "Succesfully disabled net.ipv4.ip_forward" 
	else
		LogMessage "ERROR" "Disabling net.ipv4.ip_forward. RetCode: $RetCode" 
	fi	
}

############################

case "$1" in
	start)
		LogMessage "INFO" "---- Enabling conf ----" 
		LogMessage "INFO" "starting custom fw" 
		custom_fw_start
		LogMessage "INFO" "enabling ipforward" 
		ipforward_start
		;;
	stop)
		LogMessage "INFO" "---- Disabling firewall ----"
		LogMessage "INFO" "stopping custom fw" 
		custom_fw_stop
		LogMessage "INFO" "disabling ipforward" 
		ipforward_stop
		;;
	restart)
		LogMessage "INFO" "---- Restarting firewall ----" 
		LogMessage "INFO" "stopping custom fw"
		custom_fw_stop
		LogMessage "INFO" "disabling ipforward"
		ipforward_stop
		LogMessage "INFO" "starting custom fw"
		custom_fw_start
		LogMessage "INFO" "enabling ipforward"
		ipforward_start
		;;
esac
