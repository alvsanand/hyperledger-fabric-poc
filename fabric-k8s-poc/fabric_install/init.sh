#!/bin/bash +x

export CHANNEL_NAME=${CHANNEL_NAME:="mychannel"}

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

## Generates Channel Artifacts
function generateChannelArtifacts() {
	if [ ! -d $NFS_DIRECTORY ]; then
		mkdir $NFS_DIRECTORY
	fi
	if [ ! -d ${CONFIG_PATH}/channel-artifacts ]; then
		mkdir ${CONFIG_PATH}/channel-artifacts
	fi
	if [ ! -d ${CONFIG_PATH}/crypto-config ]; then
		mkdir ${CONFIG_PATH}/crypto-config
	fi


	$CONFIGTXGEN -profile TwoOrgsOrdererGenesis -outputBlock ${CONFIG_PATH}/channel-artifacts/genesis.block
	
	chmod -R 777 ${CONFIG_PATH}/channel-artifacts && chmod -R 777 ${CONFIG_PATH}/crypto-config

	cp ${CONFIG_PATH}/channel-artifacts/genesis.block ${CONFIG_PATH}/crypto-config/ordererOrganizations/*

	cp -r ${CONFIG_PATH}/crypto-config $NFS_DIRECTORY/ && cp -r ${CONFIG_PATH}/channel-artifacts $NFS_DIRECTORY/
}

## Generates Kubernetes Yaml file
function generateK8sYaml (){
	python3.5 transform/generate.py
}

## Clean files
function clean () {
	sudo rm -Rf $NFS_DIRECTORY
	rm -Rf crypto-config
	rm -Rf channel-artifacts
}

clean
generateCerts
generateChannelArtifacts
generateK8sYaml
