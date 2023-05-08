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



###### START OF KEY PAIRS SECTION ##########################

function describesKeys(){
echo "These are your keys in AWS: " 
aws ec2 describe-key-pairs --query 'KeyPairs[*].{KeyName:KeyName,Fingerprint:Fingerprint,KeyMaterial:KeyMaterial,KeyPairId:KeyPairId}' --output table
}

function describeKey(){
	aws ec2 describe-key-pairs --query 'KeyPairs[*].{KeyName:KeyName,Fingerprint:Fingerprint,KeyMaterial:KeyMaterial,KeyPairId:KeyPairId}' --output table
	read -p "Enter a specific key name: " keyNameDescribe
		aws ec2 describe-key-pairs --key-name $keyNameDescribe
}

function createKeyPair(){
	read -p "lets check if key exists, enter a desired name: " keynameis
	watch=0
	while [[ watch -eq 0 ]]
	do
		if [[ -a ~/.ssh/$keynameis.pem ]]
			then 
				echo "Key name \"$keynameis\" is already taken!!!"
				let watch=watch+1
			else
				aws ec2 create-key-pair --key-name $keynameis --query 'KeyMaterial' --output text > ~/.ssh/$keynameis.pem ; chmod 400 ~/.ssh/$keynameis.pem
				echo -e "Key-Pair ***$keynameis*** has been successfully created in ssh directory"
				let watch=watch+1
		fi
	done
	ls -l ~/.ssh/$keynameis.pem
	sleep 3
}

function deleteKeyPair(){
	aws ec2 describe-key-pairs --query 'KeyPairs[*].{KeyName:KeyName,Fingerprint:KeyFingerprint,KeyMaterial:KeyMaterial,KeyPairId:KeyPairId}' --output table
	read -p "Enter a specific key name to delete: " keyNameDelete
		aws ec2 delete-key-pair --key-name $keyNameDelete
		echo "Key was successfully deleted!"
}


function keyMenu() {
while :
	do
		echo -e "\n\n\n***************************"
		echo          "***************************"
		echo          "MAKE YOUR CHOISE RIGHT NOW!"
		echo          "***************************"
		echo          "***************************"

			 echo "1. Describe keys"
			 echo "2. Display a specific key"
			 echo "3. Create Key-Pair"
			 echo "4. Delete Key-Pair"
			 echo "5. Quit"

		read -p "take your choice: " choice
		case $choice in
 
			1) describesKeys ;;
			2) describeKey ;;
			3) createKeyPair ;;
			4) deleteKeyPair ;;
			5) break ;;
			*) echo "nums from 1 to 5 ONLY" ; sleep 3 ;;
		esac
	done
}
###### END OF KEY PAIRS SECTION ##########################

######## START OF VPC SECTION ###########################
function createVpc(){
read -p "Enter a name for your VPC: " vpcName
read -p "Enter a cidrBlock for your VPC in format 0.0.0.0/sn : " vpcCidr
	vpcTagName=$(echo "--tag-specifications ResourceType=vpc,Tags=[{Key=Name,Value=${vpcName}}]")
	aws ec2 create-vpc --cidr-block $vpcCidr $vpcTagName
}


function displayVpcs(){
echo "Here are your VPCs: "
	#aws ec2 describe-vpcs
	aws ec2 --output table --query 'Vpcs[*].{VpcId:VpcId,Name:Tags[?Key==`Name`].Value|[0],CidrBlock:CidrBlock}' describe-vpcs
}


function describeVpc(){
	#aws ec2 describe-vpcs | grep "\"VpcId\""
	displayVpcs
	read -p "Enter a vpc id to describe: " vpcIdDescribe
	aws ec2 describe-vpcs --vpc-ids $vpcIdDescribe
}


function destroyVpc(){
	#aws ec2 describe-vpcs | grep "\"VpcId\""
	displayVpcs
	read -p "Enter a vpc id to delete: " vpcIdDel
	aws ec2 delete-vpc --vpc-id $vpcIdDel
}

function VPCMenu() {
while :
	do
		echo -e "\n\n\n***************************"
		echo          "***************************"
		echo          "MAKE YOUR CHOISE RIGHT NOW!"
		echo          "***************************"
		echo          "***************************"

			 echo "1. Display all vpcs"
			 echo "2. Describe specific VPC"
			 echo "3. Create VPC"
			 echo "4. Delete VPC"
			 echo "5. Quit"

		read -p "take your choice: " choice
		case $choice in
 
			1) displayVpcs ;;
			2) describeVpc ;;
			3) createVpc ;;
			4) destroyVpc ;;
			5) break ;;
			*) echo "nums from 1 to 5 ONLY" ; sleep 3 ;;
		esac
	done
}


######## END OF VPC SECTION ###########################


######## START OF SUBNETTING SECTION ###########################
function displaySubs(){
echo "Here are your Subnets: "
	aws ec2 describe-subnets --query 'Subnets[*].{SubnetId:SubnetId,AZ:AvailabilityZone,CidrBlock:CidrBlock,VpcId:VpcId}' --output table
}


function createSub(){
read -p "Enter a name for your Subnet: " subName
aws ec2 --output table --query 'Vpcs[*].{VpcId:VpcId,Name:Tags[?Key==`Name`].Value|[0],CidrBlock:CidrBlock}' 
describe-vpcs
read -p "Enter a VPC ID for your subnet: " subVpcid
read -p "Enter a cidrBlock for your subnet in format 0.0.0.0/sn : " subCidr
	subnetVpcId=$(echo "--vpc-id $subVpcid")
	subnetCidrID=$(echo "--cidr-block $subCidr")
	subnetTagName=$(echo "--tag-specifications ResourceType=subnet,Tags=[{Key=Name,Value=${subName}}]")
	aws ec2 create-subnet $subnetVpcId $subnetCidrID $subnetTagName
}

function describeSub(){
	displaySubs
	read -p "Enter a vpc id to describe its subnets: " subnetToDescribeVpcId
	aws ec2 describe-subnets --filters "Name=vpc-id,Values=$subnetToDescribeVpcId"
}


function destroySub(){
	displaySubs
	read -p "Enter a subnet id to delete: " subnetIdDel
	aws ec2 delete-subnet --subnet-id $subnetIdDel
}



function subMenu() {
while :
	do
		echo -e "\n\n\n***************************"
		echo          "***************************"
		echo          "MAKE YOUR CHOISE RIGHT NOW!"
		echo          "***************************"
		echo          "***************************"

			 echo "1. Display all subs"
			 echo "2. Describe specific subnet"
			 echo "3. Create subnet"
			 echo "4. Delete subnet"
			 echo "5. Quit"

		read -p "take your choice: " choice
		case $choice in
 
			1) displaySubs ;;
			2) describeSub ;;
			3) createSub ;;
			4) destroySub ;;
			5) break ;;
			*) echo "nums from 1 to 5 ONLY" ; sleep 3 ;;
		esac
	done
}


######## END OF SUBNETTING SECTION ###########################




######## START OF SECURITY GROUPSECTION ###########################
function displaySGs(){
echo "Here are your Security Groups: "
	aws ec2 describe-security-groups --query 'SecurityGroups[*].{GroupId:GroupId,GroupName:GroupName,VpcId:VpcId,Description:Description}' --output table
}


function createSG(){
read -p "Enter a name for your Security Group: " sGName
read -p "Enter a short Description of your SG - For What is it?: " SgDescription
displayVpcs
read -p "Choose what vpc id will your security group belong: " SgVpcIdBelong
aws ec2 create-security-group --group-name $sGName --description "$SgDescription" --vpc-id $SgVpcIdBelong
}

function describeSG(){
	displaySGs
	read -p "Enter a security group id to describe it: " describeSecGr
	aws ec2 describe-security-groups --group-ids $describeSecGr
}


function destroySG(){
	displaySGs
	read -p "Enter a Security Group id to delete: " SgIdDel
	aws ec2 delete-security-group --group-id $SgIdDel
}

function ingressAuth(){
displaySGs
read -p "Choose an ID of security group to create Inbound rules: " groupIA
read -p "What protocol you wanna? tcp or udp?: " protocIA
read -p "What port you wanna? nums 1-65535: " portOpenIA
read -p "What CIDR you wanna Incomming traffic from? type in format 0.0.0.0/0: " cidrIA
	aws ec2 authorize-security-group-ingress --group-id $groupIA --protocol $protocIA --port $portOpenIA --cidr $cidrIA
}

function egressAuth(){
displaySGs
read -p "Choose an ID of security group to create outbound rules: " groupEA
read -p "What protocol you wanna? tcp or udp?: " protocEA
read -p "What port you wanna? nums 1-65535: " portOpenEA
read -p "What CIDR you wanna outgoing traffic to? type in format 0.0.0.0/0: " cidrEA
	aws ec2 authorize-security-group-egress --group-id $groupEA --protocol $protocEA --port $portOpenEA --cidr $cidrEA
}

function descSGRules(){
displaySGs
read -p "Enter a security group id to describe all Security rules: " descrulesSG
aws ec2 describe-security-group-rules --filter Name="group-id",Values="$descrulesSG"
}

function descIGW(){
echo "Here are your IGWs: "
aws ec2 describe-internet-gateways --query 'InternetGateways[*].{IGWid:InternetGatewayId,VPCs:Attachments[].VpcId,State:Attachments[].State}' --output table
}

function createIGW(){
echo "creating IGW"
aws ec2 create-internet-gateway
descIGW
read -p "Enter an IGW id you wanna to attach: " atIGWid
displayVpcs
read -p "Enter a VPC id that IGW belongs it: " atIGWvpc
aws ec2 attach-internet-gateway --vpc-id $atIGWvpc --internet-gateway-id $atIGWid
}

function delIGW(){
descIGW
read -p "Enter an IGW id you wanna to detach: " delIGWid
displayVpcs
read -p "Enter a VPC id that IGW belongs it: " delIGWvpc
aws ec2 detach-internet-gateway --vpc-id $delIGWvpc --internet-gateway-id $delIGWid
aws ec2 delete-internet-gateway --internet-gateway-id $delIGWid
}

function describeRT(){
echo "these are youre Route Tables: "
aws ec2 describe-route-tables --query 'RouteTables[*].{RTID:RouteTableId,VPC:VpcId,Routes:Routes[].DestinationCidrBlock,Associations:Associations[].SubnetId}' --output table

}

function createRT(){
read -p "Enter a vpc id to create A route table for it: " vpcRT
aws ec2 create-route-table --vpc-id $vpcRT
read -p "Connect to internet? y/n: " ans
if [[ $ans == "y" ]]
	then
		describeRT
		read -p "Enter a route table ID you wanna to create a route: " RouteRTid
		descIGW
		read -p "Enter an internet gateway ID you wanna to create a route: " GWrtid
		aws ec2 create-route --route-table-id $RouteRTid --destination-cidr-block 0.0.0.0/0 --gateway-id $GWrtid
		echo "Route created, now you have to associate it with subnet id to have internet access"
	else
		echo "Okay, you will never have an Internet:)"
fi
}


function assocRT(){
		describeRT
		read -p "Enter a route table ID you wanna to associate: " assocRTid
		displaySubs
		read -p "Enter a subnet id to associate it with Route table: " assocSubNetid
		aws ec2 associate-route-table --route-table-id $assocRTid --subnet-id $assocSubNetid
}

function DeleteRT(){
echo "Enter a route table id you wanna delete: "
}

function createEIP() {
echo "elastic Ip will be created"
aws ec2 allocate-address
}

function attachEllasticIp(){
echo "there are your elastic public IPs: "
aws ec2 describe-addresses | grep "PublicIp"
read -p "Enter an elastic Ip you wanna to attach in format 0.0.0.0: " PubEIP
echo "here are your instances: "
describeEC2
read -p "Enter an instance id you wanna to attach it an elastic public ip: " InstIDEIP
aws ec2 associate-address --instance-id $InstIDEIP --public-ip $PubEIP
}

function secGroupMenu() {
while :
	do
		echo -e "\n\n\n***************************"
		echo          "***************************"
		echo          "MAKE YOUR CHOISE RIGHT NOW!"
		echo          "***************************"
		echo          "***************************"

			 echo "1. Display all SGs"
			 echo "2. Describe specific SG"
			 echo "3. Create SG"
			 echo "4. Delete SG"
			 echo "5. Create inboung rules"
			 echo "6. Create outbound rules"
			 echo "7. Describe security rules"
			 echo "8. Describe internet gateways"
			 echo "9. Create internet Gateway and attach to VPC"
			 echo "10. Detach and Delete internet gateway"
			 echo "11. Create route table"
			 echo "12. Describe route tables"
			 echo "13. Associate route table with subnet"
			 echo "14. Delete route table"
			 echo "15. create elastic IP"
			 echo "16. attach elastic IP"
			 echo "17. Quit"

		read -p "take your choice: " choice
		case $choice in
 
			1) displaySGs ;;
			2) describeSG ;;
			3) createSG ;;
			4) destroySG ;;
			5) ingressAuth ;;
			6) egressAuth ;;
			7) descSGRules ;;
			8) descIGW ;;
			9) createIGW ;;
			10) delIGW ;;
			11) createRT ;;
			12) describeRT ;;
			13) assocRT ;;
			14) DeleteRT ;;
			15) createEIP ;;
			16) attachEllasticIp ;;
			17) break ;;
			*) echo "nums from 1 to 15 ONLY" ; sleep 3 ;;
		esac
	done
#https://serverfault.com/a/876370
}


######## END OF SECURITY GROUP SECTION ###########################

#### START OF EC2 SECTION ####################
function launchEC2() {
	describesKeys
	read -p "Enter a key name: " keyName
		read -p "Enter an instance name: " iName
		displaySGs
		read -p "Enter a Security Group ID: " sguidEC2
		displaySubs
		read -p "Enter a subnet ID: " snID
		tagName=$(echo "--tag-specifications ResourceType=instance,Tags=[{Key=Name,Value=${iName}}]")
		    if [[ ! -z "$iName" ]] 
			then echo "You choosed $iName name for your instance" ; \
			aws ec2 run-instances --image-id ami-0ac64ad8517166fb1 --count 1 --instance-type t2.micro  $tagName --key-name $keyName  --security-group-ids $sguidEC2 --subnet-id $snID
			else echo "Name of your instance will be None" ; 
			aws ec2 run-instances --image-id ami-0ac64ad8517166fb1 --count 1 --instance-type t2.micro --key-name $keyName --security-group-ids $sguidEC2 --subnet-id $snID
			fi
}

function descec2() {
aws ec2 describe-instances --query "Reservations[*].Instances[*].{PublicIP:PublicIpAddress,Type:InstanceType,Name:Tags[?Key=='Name']|[0].Value,Status:State.Name,InstanceID:InstanceId}"  --filters "Name=instance-state-name,Values=*" "Name=instance-type,Values='*micro*'" --output table
}

function describeEC2(){
	descec2
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
read -p "Enter instance ids to stop: " stopids
aws ec2 stop-instances --instance-ids $stopids
}


function startEC2(){
read -p "Enter instance ids to start: " startids
aws ec2 start-instances --instance-ids $startids
}

function startAllInstances() {
allinst=$(aws ec2 describe-instances --filters  "Name=instance-state-name,Values=stopped" --query "Reservations[].Instances[].[InstanceId]" --output text | tr '\n' ',')
echo "Starting $allinst"
IFS=',' read -ra starts <<< "$allinst"
for start in "${starts[@]}" 
	do
		aws ec2 start-instances --instance-ids $start
		echo "Instance $start started"
	done
}


function stopAllInstances() {
allinst=$(aws ec2 describe-instances --filters  "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].[InstanceId]" --output text | tr '\n' ',')
echo "Stoping $allinst"
IFS=',' read -ra stops <<< "$allinst"
for stop in "${stops[@]}" 
	do
		aws ec2 stop-instances --instance-ids $stop
		echo "Instance $stop stopped"
	done
}

function destroyEC2(){
descec2
read -p "Enter instance ids to destroy: " destroyids
aws ec2 terminate-instances --instance-ids $destroyids
}

function ec2menu() {
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
			 echo "6. Start all instances"
			 echo "7. Stop All instances"
			 echo "8. Quit"

		read -p "take your choice: " choice
		case $choice in
 
			1) launchEC2 ;;
			2) destroyEC2 ;;
			3) describeEC2 ;;
			4) startEC2 ;;
			5) stopEC2 ;;
			6) startAllInstances ;;
			7) stopAllInstances ;;
			8) break ;;
			*) echo "nums from 1 to 8 ONLY" ; sleep 3 ;;
		esac
	done
}
######## END OF EC2 SECTION   ####################


############ START EBS SECTION ################

function describeEbs(){
echo "Here are your EBS volumes: "
aws ec2 describe-volumes --query "Volumes[*].{VolumeID:VolumeId,SizeVolume:Size,AZ:AvailabilityZone,Type:VolumeType,Status:State,InstancesId:Attachments[0].InstanceId,DeviceName:Attachments[0].Device}" --output table
}


function createEbs() {
read -p "Enter size in GB to create your EBS storage: " ebs_size
echo "Creating ebs storage, please wait...."
volume_id=$(aws ec2 create-volume --size $ebs_size --availability-zone us-west-2a --volume-type gp2 --query 'VolumeId' --output text)
aws ec2 wait volume-available --volume-ids $volume_id
echo "Volume created successfully and available to attach!!!"

}

function attachEbs() {
describeEbs
read -p "Enter an EBS volume to attach: " vol_id
descec2
read -p "Enter an instance id to attach to it ebs volume: " myInstanceId
aws ec2 attach-volume --volume-id $vol_id --instance-id $myInstanceId --device /dev/sdf
}

function detachEbs() {
describeEbs
read -p "Enter an EBS iD to Dettach: " vol_id
descec2
read -p "Enter an instance id to dettach from it ebs volume: " myInstanceId
aws ec2 detach-volume --volume-id $vol_id --instance-id $myInstanceId
echo "Volume was dettached successfully!"
}

function destroyEbs() {
describeEbs
read -p "Enter an EBS iD to Destroy it: " vol_id
aws ec2 delete-volume --volume-id $vol_id
echo "Volume was successfully deleted!"
}

function ebsmenu() {
while :
	do
		echo -e "\n\n\n***************************"
		echo          "***************************"
		echo          "******EBS MENU CHOICE******"
		echo          "***************************"
		echo          "***************************"

			 echo "1. Create EBS"
			 echo "2. Attach EBS"
			 echo "3. Describe EBS"
			 echo "4. Dettach EBS"
			 echo "5. Destroy EBS"
			 echo "6. Quit"

		read -p "take your choice: " choice
		case $choice in
 
			1) createEbs ;;
			2) attachEbs ;;
			3) describeEbs ;;
			4) detachEbs ;;
			5) destroyEbs ;;
			6) break ;;
			*) echo "nums from 1 to 6 ONLY" ; sleep 3 ;;
		esac
	done
}
######## END OF EBS SECTION   ####################


############ START MAIN SECTION ################

function main() {
while :
	do
		echo -e "\n\n\n***************************"
		echo          "***************************"
		echo          "MAKE YOUR CHOISE RIGHT NOW!"
		echo          "***************************"
		echo          "***************************"

			 echo "1. EC2 Menu"
			 echo "2. KeyPairMenu"
			 echo "3. VPC menu"
			 echo "4. Subnetting Menu"
			 echo "5. Security Group Menu"
			 echo "6. EBS MENU"
			 echo "7. Quit"

		read -p "take your choice: " choice
		case $choice in
 
			1) ec2menu ;;
			2) keyMenu ;;
			3) VPCMenu ;;
			4) subMenu ;;
			5) secGroupMenu ;;
			6) ebsmenu ;;
			7) break ;;
			*) echo "nums from 1 to 7 ONLY" ; sleep 3 ;;
		esac
	done
}




main
############ END MAIN SECTION ################
