#!/bin/bash

source scriptUtils.sh

function createCSP1() {

  infoln "Enroll the CA admin"
  mkdir -p organizations/peerOrganizations/CSP1.cloud.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/CSP1.cloud.com/
  #  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
  #  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://CSP1admin:CSP1cloud@localhost:7054 --caname ca-CSP1 --tls.certfiles ${PWD}/organizations/fabric-ca/CSP1/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-CSP1.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-CSP1.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-CSP1.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-CSP1.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peerOrganizations/CSP1.cloud.com/msp/config.yaml

  infoln "Register peer0"
  set -x
  fabric-ca-client register --caname ca-CSP1 --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/CSP1/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register user"
  set -x
  fabric-ca-client register --caname ca-CSP1 --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/CSP1/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register the org admin"
  set -x
  fabric-ca-client register --caname ca-CSP1 --id.name CSP1CSP1admin --id.secret CSP1CSP1cloud --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/CSP1/tls-cert.pem
  { set +x; } 2>/dev/null

  mkdir -p organizations/peerOrganizations/CSP1.cloud.com/peers
  mkdir -p organizations/peerOrganizations/CSP1.cloud.com/peers/peer0.CSP1.cloud.com

  infoln "Generate the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-CSP1 -M ${PWD}/organizations/peerOrganizations/CSP1.cloud.com/peers/peer0.CSP1.cloud.com/msp --csr.hosts peer0.CSP1.cloud.com --tls.certfiles ${PWD}/organizations/fabric-ca/CSP1/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/CSP1.cloud.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/CSP1.cloud.com/peers/peer0.CSP1.cloud.com/msp/config.yaml

  infoln "Generate the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-CSP1 -M ${PWD}/organizations/peerOrganizations/CSP1.cloud.com/peers/peer0.CSP1.cloud.com/tls --enrollment.profile tls --csr.hosts peer0.CSP1.cloud.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/CSP1/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/CSP1.cloud.com/peers/peer0.CSP1.cloud.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/CSP1.cloud.com/peers/peer0.CSP1.cloud.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/CSP1.cloud.com/peers/peer0.CSP1.cloud.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/CSP1.cloud.com/peers/peer0.CSP1.cloud.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/CSP1.cloud.com/peers/peer0.CSP1.cloud.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/CSP1.cloud.com/peers/peer0.CSP1.cloud.com/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/CSP1.cloud.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/CSP1.cloud.com/peers/peer0.CSP1.cloud.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/CSP1.cloud.com/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/CSP1.cloud.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/CSP1.cloud.com/peers/peer0.CSP1.cloud.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/CSP1.cloud.com/tlsca/tlsca.CSP1.cloud.com-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/CSP1.cloud.com/ca
  cp ${PWD}/organizations/peerOrganizations/CSP1.cloud.com/peers/peer0.CSP1.cloud.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/CSP1.cloud.com/ca/ca.CSP1.cloud.com-cert.pem

  mkdir -p organizations/peerOrganizations/CSP1.cloud.com/users
  mkdir -p organizations/peerOrganizations/CSP1.cloud.com/users/User1@CSP1.cloud.com

  infoln "Generate the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-CSP1 -M ${PWD}/organizations/peerOrganizations/CSP1.cloud.com/users/User1@CSP1.cloud.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/CSP1/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/CSP1.cloud.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/CSP1.cloud.com/users/User1@CSP1.cloud.com/msp/config.yaml

  mkdir -p organizations/peerOrganizations/CSP1.cloud.com/users/Admin@CSP1.cloud.com

  infoln "Generate the org admin msp"
  set -x
  fabric-ca-client enroll -u https://CSP1CSP1admin:CSP1CSP1cloud@localhost:7054 --caname ca-CSP1 -M ${PWD}/organizations/peerOrganizations/CSP1.cloud.com/users/Admin@CSP1.cloud.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/CSP1/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/CSP1.cloud.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/CSP1.cloud.com/users/Admin@CSP1.cloud.com/msp/config.yaml

}

function createCSP2() {

  infoln "Enroll the CA admin"
  mkdir -p organizations/peerOrganizations/CSP2.cloud.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/CSP2.cloud.com/
  #  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
  #  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://CSP2admin:CSP2cloud@localhost:8054 --caname ca-CSP2 --tls.certfiles ${PWD}/organizations/fabric-ca/CSP2/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-CSP2.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-CSP2.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-CSP2.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-CSP2.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peerOrganizations/CSP2.cloud.com/msp/config.yaml

  infoln "Register peer0"
  set -x
  fabric-ca-client register --caname ca-CSP2 --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/CSP2/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register user"
  set -x
  fabric-ca-client register --caname ca-CSP2 --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/CSP2/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register the org admin"
  set -x
  fabric-ca-client register --caname ca-CSP2 --id.name CSP2CSP2admin --id.secret CSP2CSP2cloud --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/CSP2/tls-cert.pem
  { set +x; } 2>/dev/null

  mkdir -p organizations/peerOrganizations/CSP2.cloud.com/peers
  mkdir -p organizations/peerOrganizations/CSP2.cloud.com/peers/peer0.CSP2.cloud.com

  infoln "Generate the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-CSP2 -M ${PWD}/organizations/peerOrganizations/CSP2.cloud.com/peers/peer0.CSP2.cloud.com/msp --csr.hosts peer0.CSP2.cloud.com --tls.certfiles ${PWD}/organizations/fabric-ca/CSP2/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/CSP2.cloud.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/CSP2.cloud.com/peers/peer0.CSP2.cloud.com/msp/config.yaml

  infoln "Generate the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-CSP2 -M ${PWD}/organizations/peerOrganizations/CSP2.cloud.com/peers/peer0.CSP2.cloud.com/tls --enrollment.profile tls --csr.hosts peer0.CSP2.cloud.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/CSP2/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/CSP2.cloud.com/peers/peer0.CSP2.cloud.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/CSP2.cloud.com/peers/peer0.CSP2.cloud.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/CSP2.cloud.com/peers/peer0.CSP2.cloud.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/CSP2.cloud.com/peers/peer0.CSP2.cloud.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/CSP2.cloud.com/peers/peer0.CSP2.cloud.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/CSP2.cloud.com/peers/peer0.CSP2.cloud.com/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/CSP2.cloud.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/CSP2.cloud.com/peers/peer0.CSP2.cloud.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/CSP2.cloud.com/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/CSP2.cloud.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/CSP2.cloud.com/peers/peer0.CSP2.cloud.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/CSP2.cloud.com/tlsca/tlsca.CSP2.cloud.com-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/CSP2.cloud.com/ca
  cp ${PWD}/organizations/peerOrganizations/CSP2.cloud.com/peers/peer0.CSP2.cloud.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/CSP2.cloud.com/ca/ca.CSP2.cloud.com-cert.pem

  mkdir -p organizations/peerOrganizations/CSP2.cloud.com/users
  mkdir -p organizations/peerOrganizations/CSP2.cloud.com/users/User1@CSP2.cloud.com

  infoln "Generate the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-CSP2 -M ${PWD}/organizations/peerOrganizations/CSP2.cloud.com/users/User1@CSP2.cloud.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/CSP2/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/CSP2.cloud.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/CSP2.cloud.com/users/User1@CSP2.cloud.com/msp/config.yaml

  mkdir -p organizations/peerOrganizations/CSP2.cloud.com/users/Admin@CSP2.cloud.com

  infoln "Generate the org admin msp"
  set -x
  fabric-ca-client enroll -u https://CSP2CSP2admin:CSP2CSP2cloud@localhost:8054 --caname ca-CSP2 -M ${PWD}/organizations/peerOrganizations/CSP2.cloud.com/users/Admin@CSP2.cloud.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/CSP2/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/CSP2.cloud.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/CSP2.cloud.com/users/Admin@CSP2.cloud.com/msp/config.yaml

}

function createOrderer() {

  infoln "Enroll the CA admin"
  mkdir -p organizations/ordererOrganizations/cloud.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/cloud.com
  #  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
  #  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/ordererOrganizations/cloud.com/msp/config.yaml

  infoln "Register orderer"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register the orderer admin"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  mkdir -p organizations/ordererOrganizations/cloud.com/orderers
  mkdir -p organizations/ordererOrganizations/cloud.com/orderers/cloud.com

  mkdir -p organizations/ordererOrganizations/cloud.com/orderers/orderer.cloud.com

  infoln "Generate the orderer msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/cloud.com/orderers/orderer.cloud.com/msp --csr.hosts orderer.cloud.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/cloud.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/cloud.com/orderers/orderer.cloud.com/msp/config.yaml

  infoln "Generate the orderer-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/cloud.com/orderers/orderer.cloud.com/tls --enrollment.profile tls --csr.hosts orderer.cloud.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/cloud.com/orderers/orderer.cloud.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/cloud.com/orderers/orderer.cloud.com/tls/ca.crt
  cp ${PWD}/organizations/ordererOrganizations/cloud.com/orderers/orderer.cloud.com/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/cloud.com/orderers/orderer.cloud.com/tls/server.crt
  cp ${PWD}/organizations/ordererOrganizations/cloud.com/orderers/orderer.cloud.com/tls/keystore/* ${PWD}/organizations/ordererOrganizations/cloud.com/orderers/orderer.cloud.com/tls/server.key

  mkdir -p ${PWD}/organizations/ordererOrganizations/cloud.com/orderers/orderer.cloud.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/cloud.com/orderers/orderer.cloud.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/cloud.com/orderers/orderer.cloud.com/msp/tlscacerts/tlsca.cloud.com-cert.pem

  mkdir -p ${PWD}/organizations/ordererOrganizations/cloud.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/cloud.com/orderers/orderer.cloud.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/cloud.com/msp/tlscacerts/tlsca.cloud.com-cert.pem

  mkdir -p organizations/ordererOrganizations/cloud.com/users
  mkdir -p organizations/ordererOrganizations/cloud.com/users/Admin@cloud.com

  infoln "Generate the admin msp"
  set -x
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/cloud.com/users/Admin@cloud.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/cloud.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/cloud.com/users/Admin@cloud.com/msp/config.yaml

}
