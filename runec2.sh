#!/bin/bash

############ COLOR SECTION #############

# Reset
Off='\033[0m'       # Text Reset

# Regular Colors
Greenl='\033[1;32m'        # Green Light
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[1;36m'         # Cyan
White='\033[1;97m'        # White BOLD

########## END OF COLOR SECTION #########


function launchEC2() {
	read -p "Enter a key name: !REQUIRED!! " keyName
		read -p "Enter an instance name: Not Required " iName
		tagName=$(echo "--tag-specifications ResourceType=instance,Tags=[{Key=Name,Value=${iName}}]")
		aws ec2 create-key-pair --key-name $keyName
		    if [[ ! -z "$iName" ]] 
			then echo "You choosed $iName name for your instance" ; \
			aws ec2 run-instances --image-id ami-0ac64ad8517166fb1 --count 1 --instance-type t2.micro  $tagName --key-name $keyName 
			else echo "Name of your instance will be None" ; 
			aws ec2 run-instances --image-id ami-0ac64ad8517166fb1 --count 1 --instance-type t2.micro --key-name $keyName 
			fi
}

function describeEC2(){
aws ec2 describe-instances --query "Reservations[*].Instances[*].{PublicIP:PublicIpAddress,Type:InstanceType,Name:Tags[?Key=='Name']|[0].Value,Status:State.Name,InstanceID:InstanceId}"  --filters "Name=instance-state-name,Values=*" "Name=instance-type,Values='*micro*'" --output table
	echo -ne "\t${White}All instances num:${Off} "
	aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId]' --output text | wc -l 
	echo -ne "\t${Green}Running instances:${Off} "
	aws ec2 describe-instances --query "Reservations[*].Instances[*].{PublicIP:PublicIpAddress,Type:InstanceType,Name:Tags[?Key=='Name']|[0].Value,Status:State"} | grep "\"Code\": 16" | wc -l
	echo -ne "\t${Greenl}Starting instances:${Off} "
	aws ec2 describe-instances --query "Reservations[*].Instances[*].{PublicIP:PublicIpAddress,Type:InstanceType,Name:Tags[?Key=='Name']|[0].Value,Status:State"} | grep "\"Code\": 0" | wc -l
	echo -ne "\t${Cyan}Stopping instances:${Off} "
	aws ec2 describe-instances --query "Reservations[*].Instances[*].{PublicIP:PublicIpAddress,Type:InstanceType,Name:Tags[?Key=='Name']|[0].Value,Status:State"} | grep "\"Code\": 64" | wc -l
	echo -ne "\t${Purple}Stopped instances:${Off} "
	aws ec2 describe-instances --query "Reservations[*].Instances[*].{PublicIP:PublicIpAddress,Type:InstanceType,Name:Tags[?Key=='Name']|[0].Value,Status:State"} | grep "\"Code\": 80" | wc -l
	echo -ne "\t${Red}Terminated instances:${Off} "
	aws ec2 describe-instances --query "Reservations[*].Instances[*].{PublicIP:PublicIpAddress,Type:InstanceType,Name:Tags[?Key=='Name']|[0].Value,Status:State"} | grep "\"Code\": 48" | wc -l
	echo -ne "\t${Yellow}Shutting-down instances:${Off} "
	aws ec2 describe-instances --query "Reservations[*].Instances[*].{PublicIP:PublicIpAddress,Type:InstanceType,Name:Tags[?Key=='Name']|[0].Value,Status:State"} | grep "\"Code\": 32" | wc -l
sleep 3
}


function stopEC2() {
read -p "enter instance ids to stop: " stopids
aws ec2 stop-instances --instance-ids $stopids
}


function startEC2(){
read -p "enter instance ids to start: " startids
aws ec2 start-instances --instance-ids $startids
}


function destroyEC2(){
read -p "enter instance ids to destroy: " destroyids
aws ec2 terminate-instances --instance-ids $startids
}


function main () {
while :
	do
		echo -e "\n\n\n***************************"
		echo          "***************************"
		echo          "MAKE YOUR CHOISE RIGHT NOW!"
		echo          "***************************"
		echo          "***************************"

			 echo "1. Launch EC2"
			 echo "2. Destroy EC2"
			 echo "3. Describe EC2"
			 echo "4. Start EC2"
			 echo "5. Stop EC2"
			 echo "6. Quit"

		read -p "take your choice: " choice
		case $choice in
 
			1) launchEC2 ;;
			2) destroyEC2 ;;
			3) describeEC2 ;;
			4) startEC2 ;;
			5) stopEC2 ;;
			6) break ;;
			*) echo "nums from 1 to 6 ONLY" ; sleep 3 ;;
		esac
	done
}
main
