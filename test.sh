#!/bin/bash
#############Declaring Variabes ###############
arr=$1
CIDR=$2
env=dev
app=commhub
region=us-east-2
##############Executing main commands###################
for i in ${arr[@]} 
do
	echo $i
	if [ "$i" == "k8s" ] 
	then
		echo "20 20 20 10 10 10 " > Network1.txt
		echo "[$i tags ]" > PrivateSubnetsTags.txt 
		echo "$app-$env-$i-private-$region-1a" >> PrivateSubnetsTags.txt
		echo "$app-$env-$i-private-$region-2b" >> PrivateSubnetsTags.txt
		echo "$app-$env-$i-private-$region-3c" >> PrivateSubnetsTags.txt
	elif  [ $i == "kafka" ]
	then 
		echo "20 20 20" > Network2.txt
		echo "[$i tags ]" >> PrivateSubnetsTags.txt
                echo "$app-$env-$i-private-$region-1a" >> PrivateSubnetsTags.txt
                echo "$app-$env-$i-private-$region-2b" >> PrivateSubnetsTags.txt
                echo "$app-$env-$i-private-$region-3c" >> PrivateSubnetsTags.txt

	elif   [ $i == "postgres" ]
	then 
		echo "10 10 10 " > Network3.txt
		echo "[$i tags ]" >> PrivateSubnetsTags.txt
                echo "$app-$env-$i-private-$region-1a" >> PrivateSubnetsTags.txt
                echo "$app-$env-$i-private-$region-2b" >> PrivateSubnetsTags.txt
                echo "$app-$env-$i-private-$region-3c" >> PrivateSubnetsTags.txt
	else 
		echo
              echo "Subnets will not be created for $i"
	      echo
        fi
done 
paste -d" " Network*.txt > ipcalcInput.txt
rm -rf Network*.txt
echo "Subnets required ${arr[@]} "

echo "Running IPCalc to break CIDR into Networks"
ipCalcInput=`cat ipcalcInput.txt`
exceedLimitCheck=`ipcalc $CIDR -s ${ipCalcInput} | grep "small"`
unusedSubnetCheck=`ipcalc $CIDR -s ${ipCalcInput} | grep -A 10 Unused: | grep -v Unused: | tr '\n' ' '`
echo "Value cehck ############################"
echo ${exceedLimitCheck}
echo "########################################"
if [ -z "$exceedLimitCheck" ]
then 
   echo "Networks are in range , existing CIDR is sufficient for all the subnets"
else
   echo	
   echo "Exiting CIDR is too small to create intended subnets, please adjust the subnet count for the tools"
   echo
   exit 1
fi
if [ -z "$unusedSubnetCheck" ]
   then
       echo 
       echo  "No Network is wasted , all are in use..!!!"
       echo
   else
       echo
       echo  "These subnets will remian Unused -->> $unusedSubnetCheck"
       echo  "Please make a note of unused networks , so that they can be used in future"
      echo
fi
PrivateSubnets=`ipcalc $CIDR -s ${ipCalcInput} | grep "Network" | grep "/27" | awk {'print $2'} | tr '\n' ','`
PublicSubnets=`ipcalc $CIDR -s ${ipCalcInput} | grep "Network" | grep "/28" | awk {'print $2'} | tr '\n' ','`
echo $PrivateSubnets
echo $PublicSubnets
cat PrivateSubnetsTags.txt
