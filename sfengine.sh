#!/bin/sh

/bin/rm /var/log/sfengine.log
echo "$0 $1 $2 $3 $4 $5 $6 $7 $8 $9 $10 $11 $12 $13 $14 " >> /var/log/sfengine.log


echo "Setting hostname: $HOSTNAME"  >> /var/log/sfengine.log
hostname $HOSTNAME
rm -f /etc/hostname
echo "${HOSTNAME}" >> /etc/hostname
HOSTNAME=`hostname`
echo "Hostname: $HOSTNAME" >> /var/log/sfengine.log
export HOSTNAME

BROKER_OPTIONS=$1

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



DSENGINE=/opt/DSEngine
echo "DSEngine install dir is $DSENGINE " >> /var/log/sfengine.log
cd $DSENGINE

# Check for missing shell script
ENGINE_SH=engine.sh
test -x $ENGINE_SH || { echo "$ENGINE_SH not installed";
        if [ "$0" = "stop" ]; then exit 0;
        else exit 5; fi; }

# Check for existence of needed config file
ENGINE_CONFIG=configure.sh
test -x $ENGINE_CONFIG || { echo "$ENGINE_CONFIG not existing";
        if [ "$0" = "stop" ]; then exit 0;
        else exit 6; fi; }

# init status of this service
rc=0

if [ "$0" == "start" -o "$0" == "restart" ]
then
	if [ "${BROKER_OPTIONS}" != "" ]
	then
		## Configure engine
		echo "$DSENGINE/$ENGINE_CONFIG ${BROKER_OPTIONS}" >> /var/log/sfengine.log
        	$DSENGINE/$ENGINE_CONFIG ${BROKER_OPTIONS} >> /var/log/sfengine.log 2>&1
		chown -R fabric:fabric $DSENGINE
	else
		echo "Error: no broker options found" >> /var/log/sfengine.log
        	exit 6
	fi
fi


case "$0" in
    start)
        echo "Starting engine " >> /var/log/sfengine.log

	# mount resources directory
	if [ "${RESOURCES_NFS_OPTIONS}" != "" ]
	then
		## NFS resources directory
		if  [ "${RESOURCES_NFS_MOUNT}" != "" ]
		then
			echo "Mounting ${RESOURCES_NFS_OPTIONS} " >> /var/log/sfengine.log
			mkdir -p $RESOURCES_NFS_MOUNT
			chown -R fabric $RESOURCES_NFS_MOUNT
			chgrp -R fabric $RESOURCES_NFS_MOUNT
			mount -t nfs ${RESOURCES_NFS_OPTIONS} ${RESOURCES_NFS_MOUNT}
		fi

	else
		## local resources directory
		mkdir -p /mnt/resources
		chown -R fabric /mnt/resources
		chgrp -R fabric /mnt/resources
		rm -rf ./resources
		ln -s /mnt/resources ./resources
	fi

	if [ "${DATA_NFS_OPTIONS}" != "" ]
	then
		## NFS resources directory
		if [ "${DATA_NFS_MOUNT}" != "" ]
		then
			mkdir -p $DATA_NFS_MOUNT
			chown -R fabric $DATA_NFS_MOUNT
			chgrp -R fabric $DATA_NFS_MOUNT
			echo "Mounting ${DATA_NFS_OPTIONS} " >> /var/log/sfengine.log
			mount -t nfs ${DATA_NFS_OPTIONS} ${DATA_NFS_MOUNT}
		fi
	fi

	if [ "${RESOURCES2_NFS_OPTIONS}" != "" ]
	then
		## NFS resources directory
		if [ "${RESOURCES2_NFS_MOUNT}" != "" ]
		then
			mkdir -p $RESOURCES2_NFS_MOUNT
			chown -R fabric $RESOURCES2_NFS_MOUNT
			chgrp -R fabric $RESOURCES2_NFS_MOUNT
			echo "Mounting ${RESOURCES2_NFS_OPTIONS} " >> /var/log/sfengine.log
			mount -t nfs ${RESOURCES2_NFS_OPTIONS} ${RESOURCES2_NFS_MOUNT}
		fi
	fi

	## cleanup
	/bin/rm -rf work data profiles boot.log .#dsDirID

	## setup engine session properties
	rm -rf ./engine-session.properties
	echo "azureLocation=$LOCATION" >> ./engine-session.properties
	echo "azureVmType=$VM_TYPE" >> ./engine-session.properties
	echo "azureVmName=$VM_NAME" >> ./engine-session.properties
	echo "azureVnetName=$VNET_NAME" >> ./engine-session.properties
	echo "azureSubnetName=$SUBNET_NAME" >> ./engine-session.properties
    echo "Group=$GROUP" >> ./engine-session.properties
    echo "AssetManagerId=$ASSET_MGR_ID" >> ./engine-session.properties
    echo "alternateRoutingAddress=$VM_NAME" >> ./engine-session.properties
	echo "alternateRedirectAddress=$VM_NAME" >> ./engine-session.properties

        ## Start engine
	echo "$DSENGINE/$ENGINE_SH start" >> /var/log/sfengine.log
        su --session-command="$DSENGINE/$ENGINE_SH start" fabric
	
        # Remember status and be verbose
        [ $? -ne 0 ] && rc=1 
        while [ ! -f profiles/${HOSTNAME}/pid.${HOSTNAME} ]
	do
		sleep 1
	done
        cp "profiles/${HOSTNAME}/pid.${HOSTNAME}" /opt/sfengine.pid
        ;;
    stop)
        echo "Stopping engine " >> /var/log/sfengine.log
        ## Stop engine
        su --session-command="$DSENGINE/$ENGINE_SH stop" fabric

	# umount nfs directories
	if [ "$RESOURCES_NFS_MOUNT" != "" ]
	then
		umount $RESOURCES_NFS_MOUNT
	fi

	if [ "$DATA_NFS_MOUNT" != "" ]
	then
		umount $DATA_NFS_MOUNT
	fi

	if [ "$RESOURCES2_NFS_MOUNT" != "" ]
	then
		umount $RESOURCES2_NFS_MOUNT
	fi

        # Remember status and be verbose
        [ $? -ne 0 ] && rc=1 
	rm -f /opt/sfengine.pid
        ;;
    restart)
        ## Stop the service and regardless of whether it was
        ## running or not, start it again.
        $0 stop
        $0 start

        # Remember status and be quiet
        [ $? -ne 0 ] && rc=1 
        ;;
    reload)
        ## does not support reload:
        rc=3
        ;;
    status)
        echo "Checking for service engine " >> /var/log/sfengine.log
        ## Check status with checkproc(8), if process is running
        ## checkproc will return with exit status 0.

        # Return value is slightly different for the status command:
        # 0 - service up and running
        # 1 - service dead, but /var/run/  pid  file exists
        # 2 - service dead, but /var/lock/ lock file exists
        # 3 - service not running (unused)
        # 4 - service status unknown :-(
        # 5--199 reserved (5--99 LSB, 100--149 distro, 150--199 appl.)

        # NOTE: checkproc returns LSB compliant status values.
        checkproc engine
	[ $? -ne 0 ] && rc=1
        ;;
    *)
        ## If no parameters are given, print which are avaiable.
        echo "Usage: $0 {start|stop|status|restart|reload}"
        rc=1
        ;;
esac

exit $rc
