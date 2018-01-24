#!/bin/bash

echo
echo " ____    _____      _      ____    _____ "
echo "/ ___|  |_   _|    / \    |  _ \  |_   _|"
echo "\___ \    | |     / _ \   | |_) |   | |  "
echo " ___) |   | |    / ___ \  |  _ <    | |  "
echo "|____/    |_|   /_/   \_\ |_| \_\   |_|  "
echo
echo "Build bankingfederation.com Network"
echo
CHANNEL_NAME="$1"
DELAY="$2"
: ${CHANNEL_NAME:="pb2mbw"}
: ${TIMEOUT:="60"}
COUNTER=1
MAX_RETRY=5
ORDERER_CA=/opt/gopath/src/bankingfederation.com/crypto/ordererOrganizations/bankingfederation.com/orderers/orderer.bankingfederation.com/msp/tlscacerts/tlsca.bankingfederation.com-cert.pem

CHAINCODE_LANGUAGE=${CHAINCODE_LANGUAGE:="golang"}
CHAINCODE_DIR=${CHAINCODE_DIR:="bankingfederation.com/chaincode"}
CHAINCODE_NAME=${CHAINCODE_NAME:="bankingfederation"}


echo "Channel name : "$CHANNEL_NAME

# verify the result of the end-to-end test
verifyResult () {
	if [ $1 -ne 0 ] ; then
		echo "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
    echo "========= ERROR !!! FAILED to execute End-2-End Scenario ==========="
		echo
   		exit 1
	fi
}

setGlobals () {
	if [ $1 -eq 0 -o $1 -eq 1 ] ; then
		CORE_PEER_LOCALMSPID="PartnersBankMSP"
		CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/bankingfederation.com/crypto/peerOrganizations/partnersbank.bankingfederation.com/peers/peer0.partnersbank.bankingfederation.com/tls/ca.crt
		CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/bankingfederation.com/crypto/peerOrganizations/partnersbank.bankingfederation.com/users/Admin@partnersbank.bankingfederation.com/msp
		if [ $1 -eq 0 ]; then
			CORE_PEER_ADDRESS=peer0.partnersbank.bankingfederation.com:7051
		else
			CORE_PEER_ADDRESS=peer1.partnersbank.bankingfederation.com:7051
			CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/bankingfederation.com/crypto/peerOrganizations/partnersbank.bankingfederation.com/users/Admin@partnersbank.bankingfederation.com/msp
		fi
	else
		CORE_PEER_LOCALMSPID="MultiBankWestMSP"
		CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/bankingfederation.com/crypto/peerOrganizations/multibankwest.bankingfederation.com/peers/peer0.multibankwest.bankingfederation.com/tls/ca.crt
		CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/bankingfederation.com/crypto/peerOrganizations/multibankwest.bankingfederation.com/users/Admin@multibankwest.bankingfederation.com/msp
		if [ $1 -eq 2 ]; then
			CORE_PEER_ADDRESS=peer0.multibankwest.bankingfederation.com:7051
		else
			CORE_PEER_ADDRESS=peer1.multibankwest.bankingfederation.com:7051
		fi
	fi

	env |grep CORE
}

createChannel() {
	setGlobals 0

  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
		peer channel create -o orderer.bankingfederation.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx >&log.txt
	else
		peer channel create -o orderer.bankingfederation.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
	fi
	res=$?
	cat log.txt
	verifyResult $res "Channel creation failed"
	echo "===================== Channel \"$CHANNEL_NAME\" is created successfully ===================== "
	echo
}

updateAnchorPeers() {
  PEER=$1
  setGlobals $PEER

  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
		peer channel update -o orderer.bankingfederation.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx >&log.txt
	else
		peer channel update -o orderer.bankingfederation.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
	fi
	res=$?
	cat log.txt
	verifyResult $res "Anchor peer update failed"
	echo "===================== Anchor peers for org \"$CORE_PEER_LOCALMSPID\" on \"$CHANNEL_NAME\" is updated successfully ===================== "
	sleep $DELAY
	echo
}

## Sometimes Join takes time hence RETRY atleast for 5 times
joinWithRetry () {
	peer channel join -b $CHANNEL_NAME.block  >&log.txt
	res=$?
	cat log.txt
	if [ $res -ne 0 -a $COUNTER -lt $MAX_RETRY ]; then
		COUNTER=` expr $COUNTER + 1`
		echo "PEER$1 failed to join the channel, Retry after 2 seconds"
		sleep $DELAY
		joinWithRetry $1
	else
		COUNTER=1
	fi
  verifyResult $res "After $MAX_RETRY attempts, PEER$ch has failed to Join the Channel"
}

joinChannel () {
	for ch in 0 1 2 3; do
		setGlobals $ch
		joinWithRetry $ch
		echo "===================== PEER$ch joined on the channel \"$CHANNEL_NAME\" ===================== "
		sleep $DELAY
		echo
	done
}

installChaincode () {
	PEER=$1
	setGlobals $PEER

	peer chaincode install -n $CHAINCODE_NAME -v 1.0 -p $CHAINCODE_DIR -l $CHAINCODE_LANGUAGE >&log.txt
	res=$?
	cat log.txt
        verifyResult $res "Chaincode installation on remote peer PEER$PEER has Failed"
	echo "===================== Chaincode is installed on remote peer PEER$PEER ===================== "
	echo
}

instantiateChaincode () {
	PEER=$1
	setGlobals $PEER
	# while 'peer chaincode' command can get the orderer endpoint from the peer (if join was successful),
	# lets supply it directly as we know it using the "-o" option
	if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
		peer chaincode instantiate -o orderer.bankingfederation.com:7050 -C $CHANNEL_NAME -n $CHAINCODE_NAME -v 1.0 -c '{"Args":["init","a","100","b","200"]}' -P "OR	('PartnersBankMSP.member','MultiBankWestMSP.member')" -l $CHAINCODE_LANGUAGE >&log.txt
	else
		peer chaincode instantiate -o orderer.bankingfederation.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n $CHAINCODE_NAME -v 1.0 -c '{"Args":["init","a","100","b","200"]}' -P "OR	('PartnersBankMSP.member','MultiBankWestMSP.member')" -l $CHAINCODE_LANGUAGE >&log.txt
	fi
	res=$?
	cat log.txt
	verifyResult $res "Chaincode instantiation on PEER$PEER on channel '$CHANNEL_NAME' failed"
	echo "===================== Chaincode Instantiation on PEER$PEER on channel '$CHANNEL_NAME' is successful ===================== "
	echo
}

chaincodeQuery () {
  PEER=$1
  echo "===================== Querying on PEER$PEER on channel '$CHANNEL_NAME'... ===================== "
  setGlobals $PEER
  local rc=1
  local starttime=$(date +%s)

  # continue to poll
  # we either get a successful response, or reach TIMEOUT
  while test "$(($(date +%s)-starttime))" -lt "$TIMEOUT" -a $rc -ne 0
  do
     sleep $DELAY
     echo "Attempting to Query PEER$PEER ...$(($(date +%s)-starttime)) secs"
     peer chaincode query -C $CHANNEL_NAME -n $CHAINCODE_NAME -c '{"Args":["query","a"]}' >&log.txt
     test $? -eq 0 && VALUE=$(cat log.txt | awk '/Query Result/ {print $NF}')
     test "$VALUE" = "$2" && let rc=0
  done
  echo
  cat log.txt
  if test $rc -eq 0 ; then
	echo "===================== Query on PEER$PEER on channel '$CHANNEL_NAME' is successful ===================== "
  else
	echo "!!!!!!!!!!!!!!! Query result on PEER$PEER is INVALID !!!!!!!!!!!!!!!!"
        echo "================== ERROR !!! FAILED to execute End-2-End Scenario =================="
	echo
	exit 1
  fi
}

chaincodeInvoke () {
	PEER=$1
	setGlobals $PEER
	# while 'peer chaincode' command can get the orderer endpoint from the peer (if join was successful),
	# lets supply it directly as we know it using the "-o" option
	if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
		peer chaincode invoke -o orderer.bankingfederation.com:7050 -C $CHANNEL_NAME -n $CHAINCODE_NAME -c '{"Args":["invoke","a","b","10"]}' >&log.txt
	else
		peer chaincode invoke -o orderer.bankingfederation.com:7050  --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n $CHAINCODE_NAME -c '{"Args":["invoke","a","b","10"]}' >&log.txt
	fi
	res=$?
	cat log.txt
	verifyResult $res "Invoke execution on PEER$PEER failed "
	echo "===================== Invoke transaction on PEER$PEER on channel '$CHANNEL_NAME' is successful ===================== "
	echo
}

## Create channel
echo "Creating channel..."
createChannel

## Join all the peers to the channel
echo "Having all peers join the channel..."
joinChannel

## Set the anchor peers for each org in the channel
echo "Updating anchor peers for partnersbank..."
updateAnchorPeers 0
echo "Updating anchor peers for multibankwest..."
updateAnchorPeers 2

## Install chaincode on Peer0/PartnersBank and Peer2/MultiBankWest
for i in $(seq 0 3); do
	echo "Installing chaincode on peer$i..."
	installChaincode $i
done

#Instantiate chaincode on Peer2/MultiBankWest
echo "Instantiating chaincode on multibankwest/peer2..."
instantiateChaincode 2

#Query on chaincode on Peer0/PartnersBank
echo "Querying chaincode on partnersbank/peer0..."
chaincodeQuery 0 100

#Invoke on chaincode on Peer0/PartnersBank
echo "Sending invoke transaction on partnersbank/peer0..."
chaincodeInvoke 0

#Query on chaincode on Peer3/MultiBankWest, check if the result is 90
echo "Querying chaincode on multibankwest/peer3..."
chaincodeQuery 3 90

echo
echo "========= All GOOD, Build bankingfederation.com execution completed =========== "
echo

echo
echo " _____   _   _   ____   "
echo "| ____| | \ | | |  _ \  "
echo "|  _|   |  \| | | | | | "
echo "| |___  | |\  | | |_| | "
echo "|_____| |_| \_| |____/  "
echo

exit 0
