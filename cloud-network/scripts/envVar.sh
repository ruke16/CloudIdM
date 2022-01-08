#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This is a collection of bash functions used by different scripts

source scriptUtils.sh

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/cloud.com/orderers/orderer.cloud.com/msp/tlscacerts/tlsca.cloud.com-cert.pem
export PEER0_CSP1_CA=${PWD}/organizations/peerOrganizations/CSP1.cloud.com/peers/peer0.CSP1.cloud.com/tls/ca.crt
export PEER0_CSP2_CA=${PWD}/organizations/peerOrganizations/CSP2.cloud.com/peers/peer0.CSP2.cloud.com/tls/ca.crt
export PEER0_CSP3_CA=${PWD}/organizations/peerOrganizations/CSP3.cloud.com/peers/peer0.CSP3.cloud.com/tls/ca.crt

# Set OrdererOrg.Admin globals
setOrdererGlobals() {
  export CORE_PEER_LOCALMSPID="OrdererMSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/ordererOrganizations/cloud.com/orderers/orderer.cloud.com/msp/tlscacerts/tlsca.cloud.com-cert.pem
  export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/ordererOrganizations/cloud.com/users/Admin@cloud.com/msp
}

# Set environment variables for the peer org
setGlobals() {
  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  infoln "Using cloud ${USING_ORG}"
  if [ $USING_ORG -eq 1 ]; then
    export CORE_PEER_LOCALMSPID="CSP1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_CSP1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/CSP1.cloud.com/users/Admin@CSP1.cloud.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
  elif [ $USING_ORG -eq 2 ]; then
    export CORE_PEER_LOCALMSPID="CSP2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_CSP2_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/CSP2.cloud.com/users/Admin@CSP2.cloud.com/msp
    export CORE_PEER_ADDRESS=localhost:9051

  elif [ $USING_ORG -eq 3 ]; then
    export CORE_PEER_LOCALMSPID="CSP3MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_CSP3_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/CSP3.cloud.com/users/Admin@CSP3.cloud.com/msp
    export CORE_PEER_ADDRESS=localhost:11051
  else
    errorln "CSP Unknown"
  fi

  if [ "$VERBOSE" == "true" ]; then
    env | grep CORE
  fi
}

# parsePeerConnectionParameters $@
# Helper function that sets the peer connection parameters for a chaincode
# operation
parsePeerConnectionParameters() {

  PEER_CONN_PARMS=""
  PEERS=""
  while [ "$#" -gt 0 ]; do
    setGlobals $1
    PEER="peer0.CSP$1"
    ## Set peer addresses
    PEERS="$PEERS $PEER"
    PEER_CONN_PARMS="$PEER_CONN_PARMS --peerAddresses $CORE_PEER_ADDRESS"
    ## Set path to TLS certificate
    TLSINFO=$(eval echo "--tlsRootCertFiles \$PEER0_CSP$1_CA")
    PEER_CONN_PARMS="$PEER_CONN_PARMS $TLSINFO"
    # shift by one to get to the next organization
    shift
  done
  # remove leading space for output
  PEERS="$(echo -e "$PEERS" | sed -e 's/^[[:space:]]*//')"
}

verifyResult() {
  if [ $1 -ne 0 ]; then
    fatalln "$2"
  fi
}
