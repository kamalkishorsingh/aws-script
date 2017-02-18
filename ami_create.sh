#!/bin/bash
Date_Today=`date +%Y-%m-%d-%H-%M`
Instance_Id="*****************"
OWNER="*****id******"
Instance_Catagory="test-ami"
Description=`echo "test-ami_$Date_Today"`
NAME=`echo "test_ami_$Date_Today"`
Image_Id=`aws ec2 create-image --instance-id=$Instance_Id --no-reboot --name=$NAME --description=$Description --output=text`
echo "$Image_Id"
STATE=`aws ec2 describe-images --image-ids=$Image_Id --owners=$OWNER --output=text --query Images[].State`
while [ "$STATE" == "pending" ]
do
echo "image creation in progress"
echo "waiting.."
sleep 5
STATE=`aws ec2 describe-images --image-ids=$Image_Id --owners=$OWNER --output=text --query Images[].State`
done
echo "Image Backup Done..."
####### Deletion Policy...
Old_Date=`date -d '2 days ago' +%Y-%m-%d`
Old_Image_Id=`aws ec2 describe-images --owners=$OWNER --output=text | grep $Instance_Catagory | grep "$Old_Date" | awk '{print $6}'`
for i in `echo $Old_Image_Id`
do
SNAP_ID=`aws ec2 describe-images --owners=$OWNER --image-ids=$i --output=text --query=Images[].BlockDeviceMappings[].Ebs[].SnapshotId`
echo "Deregistering  old image.. $i"
echo $i
aws ec2 deregister-image --output=text --image-id=$i
for j in `echo $SNAP_ID`
do
aws ec2 delete-snapshot --output=text --snapshot-id=$j
done
done

