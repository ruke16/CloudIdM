

function createCSP3 {

  echo
	echo "Enroll the CA admin of CSP3"
  echo
	mkdir -p ../organizations/peerOrganizations/CSP3.cloud.com/

	export FABRIC_CA_CLIENT_HOME=${PWD}/../organizations/peerOrganizations/CSP3.cloud.com/
#  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
#  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://CSP3admin:CSP3cloud@localhost:11054 --caname ca-CSP3 --tls.certfiles ${PWD}/fabric-ca/CSP3/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-CSP3.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-CSP3.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-CSP3.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-CSP3.pem
    OrganizationalUnitIdentifier: orderer' > ${PWD}/../organizations/peerOrganizations/CSP3.cloud.com/msp/config.yaml

  echo
	echo "Register peer0 of CSP3"
  echo
  set -x
	fabric-ca-client register --caname ca-CSP3 --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/CSP3/tls-cert.pem
  { set +x; } 2>/dev/null

  echo
  echo "Register user of CSP3"
  echo
  set -x
  fabric-ca-client register --caname ca-CSP3 --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/fabric-ca/CSP3/tls-cert.pem
  { set +x; } 2>/dev/null

  echo
  echo "Register the CSP3 admin"
  echo
  set -x
  fabric-ca-client register --caname ca-CSP3 --id.name CSP3CSP3admin --id.secret CSP3CSP3cloud --id.type admin --tls.certfiles ${PWD}/fabric-ca/CSP3/tls-cert.pem
  { set +x; } 2>/dev/null

	mkdir -p ../organizations/peerOrganizations/CSP3.cloud.com/peers
  mkdir -p ../organizations/peerOrganizations/CSP3.cloud.com/peers/peer0.CSP3.cloud.com

  echo
  echo "## Generate the peer0 msp for CSP3"
  echo
  set -x
	fabric-ca-client enroll -u https://peer0:peer0pw@localhost:11054 --caname ca-CSP3 -M ${PWD}/../organizations/peerOrganizations/CSP3.cloud.com/peers/peer0.CSP3.cloud.com/msp --csr.hosts peer0.CSP3.cloud.com --tls.certfiles ${PWD}/fabric-ca/CSP3/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/../organizations/peerOrganizations/CSP3.cloud.com/msp/config.yaml ${PWD}/../organizations/peerOrganizations/CSP3.cloud.com/peers/peer0.CSP3.cloud.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates for CSP3"
  echo
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:11054 --caname ca-CSP3 -M ${PWD}/../organizations/peerOrganizations/CSP3.cloud.com/peers/peer0.CSP3.cloud.com/tls --enrollment.profile tls --csr.hosts peer0.CSP3.cloud.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/CSP3/tls-cert.pem
  { set +x; } 2>/dev/null


  cp ${PWD}/../organizations/peerOrganizations/CSP3.cloud.com/peers/peer0.CSP3.cloud.com/tls/tlscacerts/* ${PWD}/../organizations/peerOrganizations/CSP3.cloud.com/peers/peer0.CSP3.cloud.com/tls/ca.crt
  cp ${PWD}/../organizations/peerOrganizations/CSP3.cloud.com/peers/peer0.CSP3.cloud.com/tls/signcerts/* ${PWD}/../organizations/peerOrganizations/CSP3.cloud.com/peers/peer0.CSP3.cloud.com/tls/server.crt
  cp ${PWD}/../organizations/peerOrganizations/CSP3.cloud.com/peers/peer0.CSP3.cloud.com/tls/keystore/* ${PWD}/../organizations/peerOrganizations/CSP3.cloud.com/peers/peer0.CSP3.cloud.com/tls/server.key

  mkdir ${PWD}/../organizations/peerOrganizations/CSP3.cloud.com/msp/tlscacerts
  cp ${PWD}/../organizations/peerOrganizations/CSP3.cloud.com/peers/peer0.CSP3.cloud.com/tls/tlscacerts/* ${PWD}/../organizations/peerOrganizations/CSP3.cloud.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/../organizations/peerOrganizations/CSP3.cloud.com/tlsca
  cp ${PWD}/../organizations/peerOrganizations/CSP3.cloud.com/peers/peer0.CSP3.cloud.com/tls/tlscacerts/* ${PWD}/../organizations/peerOrganizations/CSP3.cloud.com/tlsca/tlsca.CSP3.cloud.com-cert.pem

  mkdir ${PWD}/../organizations/peerOrganizations/CSP3.cloud.com/ca
  cp ${PWD}/../organizations/peerOrganizations/CSP3.cloud.com/peers/peer0.CSP3.cloud.com/msp/cacerts/* ${PWD}/../organizations/peerOrganizations/CSP3.cloud.com/ca/ca.CSP3.cloud.com-cert.pem

  mkdir -p ../organizations/peerOrganizations/CSP3.cloud.com/users
  mkdir -p ../organizations/peerOrganizations/CSP3.cloud.com/users/User1@CSP3.cloud.com

  echo
  echo "## Generate the user msp for CSP3"
  echo
  set -x
	fabric-ca-client enroll -u https://user1:user1pw@localhost:11054 --caname ca-CSP3 -M ${PWD}/../organizations/peerOrganizations/CSP3.cloud.com/users/User1@CSP3.cloud.com/msp --tls.certfiles ${PWD}/fabric-ca/CSP3/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/../organizations/peerOrganizations/CSP3.cloud.com/msp/config.yaml ${PWD}/../organizations/peerOrganizations/CSP3.cloud.com/users/User1@CSP3.cloud.com/msp/config.yaml

  mkdir -p ../organizations/peerOrganizations/CSP3.cloud.com/users/Admin@CSP3.cloud.com

  echo
  echo "## Generate the hosp 3 admin msp"
  echo
  set -x
	fabric-ca-client enroll -u https://CSP3CSP3admin:CSP3CSP3cloud@localhost:11054 --caname ca-CSP3 -M ${PWD}/../organizations/peerOrganizations/CSP3.cloud.com/users/Admin@CSP3.cloud.com/msp --tls.certfiles ${PWD}/fabric-ca/CSP3/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/../organizations/peerOrganizations/CSP3.cloud.com/msp/config.yaml ${PWD}/../organizations/peerOrganizations/CSP3.cloud.com/users/Admin@CSP3.cloud.com/msp/config.yaml

}
