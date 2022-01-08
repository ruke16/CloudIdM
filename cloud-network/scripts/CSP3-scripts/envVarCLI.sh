#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This is a collection of bash functions used by different scripts

ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/ordererOrganizations/cloud.com/orderers/orderer.cloud.com/msp/tlscacerts/tlsca.cloud.com-cert.pem
PEER0_CSP1_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/CSP1.cloud.com/peers/peer0.CSP1.cloud.com/tls/ca.crt
PEER0_CSP2_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/CSP2.cloud.com/peers/peer0.CSP2.cloud.com/tls/ca.crt
PEER0_CSP3_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/CSP3.cloud.com/peers/peer0.CSP3.cloud.com/tls/ca.crt

# Set OrdererOrg.Admin globals
setOrdererGlobals() {
  CORE_PEER_LOCALMSPID="OrdererMSP"
  CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/ordererOrganizations/cloud.com/orderers/orderer.cloud.com/msp/tlscacerts/tlsca.cloud.com-cert.pem
  CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/ordererOrganizations/cloud.com/users/Admin@cloud.com/msp
}

# Set environment variables for the peer org
setGlobals() {
  ORG=$1
  if [ $ORG -eq 1 ]; then
    CORE_PEER_LOCALMSPID="CSP1MSP"
    CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_CSP1_CA
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/CSP1.cloud.com/users/Admin@CSP1.cloud.com/msp
    CORE_PEER_ADDRESS=peer0.CSP1.cloud.com:7051
  elif [ $ORG -eq 2 ]; then
    CORE_PEER_LOCALMSPID="CSP2MSP"
    CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_CSP2_CA
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/CSP2.cloud.com/users/Admin@CSP2.cloud.com/msp
    CORE_PEER_ADDRESS=peer0.CSP2.cloud.com:9051
  elif [ $ORG -eq 3 ]; then
    CORE_PEER_LOCALMSPID="CSP3MSP"
    CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_CSP3_CA
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/CSP3.cloud.com/users/Admin@CSP3.cloud.com/msp
    CORE_PEER_ADDRESS=peer0.CSP3.cloud.com:11051
  else
    echo "================== ERROR !!! ORG Unknown =================="
  fi

  if [ "$VERBOSE" == "true" ]; then
    env | grep CORE
  fi
}

verifyResult() {
  if [ $1 -ne 0 ]; then
    echo $'\e[1;31m'!!!!!!!!!!!!!!! $2 !!!!!!!!!!!!!!!!$'\e[0m'
    echo
    exit 1
  fi
}
