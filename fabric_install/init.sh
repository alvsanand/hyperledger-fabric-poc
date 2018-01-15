#!/bin/bash +x

CHANNEL_NAME=$1:${CHANNEL_NAME:="mychannel"}

export NFS_DIRECTORY=${NFS_DIRECTORY:="/var/nfs/fabric"}
export NFS_SERVER=${NFS_SERVER:=$(hostname -I | awk -F" " '{print $1}')}

export CONFIG_PATH=${CONFIG_PATH:=$PWD}
export FABRIC_CFG_PATH=${CONFIG_PATH:=$PWD}
export FABRIC_TOOLS_PATH=${FABRIC_TOOLS_PATH:="$HOME/fabric-tools"}


CONFIGTXGEN=$FABRIC_TOOLS_PATH/bin/configtxgen
CRYPTOGEN=$FABRIC_TOOLS_PATH/bin/cryptogen

## Generates Org certs
function generateCerts (){

	$CRYPTOGEN generate --config=${CONFIG_PATH}/cluster-config.yaml	
}

function generateChannelArtifacts() {
	if [ ! -d channel-artifacts ]; then
		mkdir channel-artifacts
	fi
	if [ ! -d $NFS_DIRECTORY ]; then
		mkdir $NFS_DIRECTORY
	fi


	$CONFIGTXGEN -profile TwoOrgsOrdererGenesis -outputBlock ${CONFIG_PATH}/channel-artifacts/genesis.block
# 	$CONFIGTXGEN -profile TwoOrgsChannel -outputCreateChannelTx ${CONFIG_PATH}/channel-artifacts/channel.tx -channelID $CHANNEL_NAME
#	$CONFIGTXGEN -profile TwoOrgsChannel -outputAnchorPeersUpdate ${CONFIG_PATH}/channel-artifacts/Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP
# 	$CONFIGTXGEN -profile TwoOrgsChannel -outputAnchorPeersUpdate ${CONFIG_PATH}/channel-artifacts/Org2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org2MSP
# 	$CONFIGTXGEN -profile TwoOrgsChannel -outputAnchorPeersUpdate ${CONFIG_PATH}/channel-artifacts/Org3MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org3MSP
	
	chmod -R 777 ${CONFIG_PATH}/channel-artifacts && chmod -R 777 ${CONFIG_PATH}/crypto-config

	cp ${CONFIG_PATH}/channel-artifacts/genesis.block ${CONFIG_PATH}/crypto-config/ordererOrganizations/*

	cp -r ${CONFIG_PATH}/crypto-config $NFS_DIRECTORY/ && cp -r ${CONFIG_PATH}/channel-artifacts $NFS_DIRECTORY/
	#$NFS_DIRECTORY mouts the remote $NFS_DIRECTORY from nfs server
}

function generateK8sYaml (){
	python3.5 transform/generate.py
}

function clean () {
	rm -rf $NFS_DIRECTORY/crypto-config/*
	rm -rf crypto-config
}

## Genrates orderer genesis block, channel configuration transaction and anchor peer upddate transactions
##function generateChannelArtifacts () {
##	CONFIGTXGEN=configtxgen
	
#}

clean
generateCerts
generateChannelArtifacts
generateK8sYaml
