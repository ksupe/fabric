
@echo "$0 $1 $2 $3 $4 $5 $6 $7 $8 $9 $10 $11 $12 $13 $14 $15 $16" >> /var/log/sfengine.log




BROKER_OPTIONS="-s $1:8000"

echo "Broker options: $BROKER_OPTIONS " >> /var/log/sfengine.log

RESOURCES_NFS_OPTIONS=$2
echo "Resources nfs mount options: $RESOURCES_NFS_OPTIONS " >> /var/log/sfengine.log

RESOURCES_NFS_MOUNT=$3
echo "Resources nfs local mount point: $RESOURCES_NFS_MOUNT " >> /var/log/sfengine.log

DATA_NFS_OPTIONS=$4
echo "Data nfs options: $DATA_NFS_OPTIONS " >> /var/log/sfengine.log

DATA_NFS_MOUNT=$5
echo "Data nfs mount: $DATA_NFS_MOUNT " >> /var/log/sfengine.log

RESOURCES2_NFS_OPTIONS=$6
echo "Resource2 nfs options: $RESOURCES2_NFS_OPTIONS " >> /var/log/sfengine.log

RESOURCES2_NFS_MOUNT=$7
echo "Resource2 nfs mount: $RESOURCES2_NFS_MOUNT " >> /var/log/sfengine.log

GROUP=$8
echo "Group: $GROUP " >> /var/log/sfengine.log

ASSET_MGR_ID=$9
echo "Asset Manager Id: $ASSET_MGR_ID " >> /var/log/sfengine.log

LOCATION=$10

VM_TYPE=$11

VM_NAME=$12

VNET_NAME=$13

SUBNET_NAME=$14

ADMINUSER=$15

ADMINPWD=$16


