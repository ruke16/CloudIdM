/**
 * @author Ruks
 * @email ruks@hotmail.com
 * @create date 2021-12-01 13:26:42
 * @modify date 2021-12-14 20:52:37
 * @desc The file which interacts with the fabric network.
 */


const {Gateway, Wallets} = require('fabric-network');
const FabricCAServices = require('fabric-ca-client');
const path = require('path');
const {buildCAClient, registerAndEnrollUser} = require('./CAUtil.js');
const {buildCCPCSP3, buildCCPCSP2, buildCCPCSP1, buildWallet} = require('./AppUtil.js');

const channelName = 'cloudchannel';
const chaincodeName = 'cloud';
const mspOrg1 = 'CSP1MSP';
const mspOrg2 = 'CSP2MSP';
const mspOrg3 = 'CSP3MSP';
const walletPath = path.join(__dirname, 'wallet');


/**
 * @author Ruks
 * @param  {string} cloudmgrID
 * @return {networkObj} networkObj if all paramters are correct, the networkObj consists of contract, network, gateway
 * @return {string} response error if there is a error in the method
 * @description Connects to the network using the username - cloudmgrID, networkObj contains the paramters using which
 * @description a connection to the fabric network is possible.
 */
exports.connectToNetwork = async function(cloudmgrID) {
  const gateway = new Gateway();
  const ccp = buildCCPCSP1();

  try {
    const walletPath = path.join(process.cwd(), '../cloud-asset-transfer/application-javascript/wallet/');

    const wallet = await buildWallet(Wallets, walletPath);

    const userExists = await wallet.get(cloudmgrID);
    if (!userExists) {
      console.log('An identity for the cloudmgrID: ' + cloudmgrID + ' does not exist in the wallet');
      console.log('Create the cloudmgrID before retrying');
      const response = {};
      response.error = 'An identity for the user ' + cloudmgrID + ' does not exist in the wallet. Register ' + cloudmgrID + ' first';
      return response;
    }

    /**
    * setup the gateway instance
    *  he user will now be able to create connections to the fabric network and be able to
    * ubmit transactions and query. All transactions submitted by this gateway will be
    * signed by this user using the credentials stored in the wallet.
    */
    // using asLocalhost as this gateway is using a fabric network deployed locally
    await gateway.connect(ccp, {wallet, identity: cloudmgrID, discovery: {enabled: true, asLocalhost: true}});

    // Build a network instance based on the channel where the smart contract is deployed
    const network = await gateway.getNetwork(channelName);

    // Get the contract from the network.
    const contract = network.getContract(chaincodeName);

    const networkObj = {
      contract: contract,
      network: network,
      gateway: gateway,
    };
    console.log('Succesfully connected to the network.');
    return networkObj;
  } catch (error) {
    console.log(`Error processing transaction. ${error}`);
    console.log(error.stack);
    const response = {};
    response.error = error;
    return response;
  }
};


/**
 * @author Ruks
 * @param  {*} networkObj the object which is given when connectToNetwork is executed
 * @param  {boolean} isQuery true if retieving from ledger, else false in the case of add a transaction to the ledger.
 * @param  {string} func must be the function name in the chaincode.
 * @param  {string} args - a json string, if there are mutiple args, the args must be a json as one string
 * @return {string} response if the transaction was successful
 * @return {string} response error otherwise
 * @description A common function to interact with the ledger
 */
exports.invoke = async function(networkObj, isQuery, func, args= '') {
  try {
    if (isQuery === true) {
      const response = await networkObj.contract.evaluateTransaction(func, args);
      console.log(response);
      await networkObj.gateway.disconnect();
      return response;
    } else {
      if (args) {
        args = JSON.parse(args[0]);
        args = JSON.stringify(args);
      }
      const response = await networkObj.contract.submitTransaction(func, args);
      await networkObj.gateway.disconnect();
      return response;
    }
  } catch (error) {
    const response = {};
    response.error = error;
    console.error(`Failed to submit transaction: ${error}`);
    return response;
  }
};

/**
 * @author Ruks
 * @param  {string} attributes JSON string in which userId, CSPId and role must be present.
 * @description For cloud attributes also contain the cloud object
 * @description Creates a cloud/cloudmgr and adds to the wallet to the given CSPId
 */
exports.registerUser = async function(attributes) {
  const attrs = JSON.parse(attributes);
  const CSPId = parseInt(attrs.CSPId);
  const userId = attrs.userId;

  if (!userId || !CSPId) {
    const response = {};
    response.error = 'Error! You need to fill all fields before you can register!';
    return response;
  }

  try {
    const wallet = await buildWallet(Wallets, walletPath);
    // TODO: Must be handled in a config file instead of using if
    if (CSPId === 1) {
      const ccp = buildCCPCSP1();
      const caClient = buildCAClient(FabricCAServices, ccp, 'ca.CSP1.cloud.com');
      await registerAndEnrollUser(caClient, wallet, mspOrg1, userId, 'CSP1admin', attributes);
    } else if (CSPId === 2) {
      const ccp = buildCCPCSP2();
      const caClient = buildCAClient(FabricCAServices, ccp, 'ca.CSP2.cloud.com');
      await registerAndEnrollUser(caClient, wallet, mspOrg2, userId, 'CSP2admin', attributes);
    } else if (CSPId === 3) {
      const ccp = buildCCPCSP3();
      const caClient = buildCAClient(FabricCAServices, ccp, 'ca.CSP3.cloud.com');
      await registerAndEnrollUser(caClient, wallet, mspOrg3, userId, 'CSP3admin', attributes);
    }
    console.log(`Successfully registered user: + ${userId}`);
    const response = 'Successfully registered user: '+ userId;
    return response;
  } catch (error) {
    console.error(`Failed to register user + ${userId} + : ${error}`);
    const response = {};
    response.error = error;
    return response;
  }
};

/**
 * @param  {NetworkObj} networkObj The object which is generated when connectToNetwork is executed
 * @param  {Number} CSPId
 * @return {JSON} Returns an JSON array consisting of all cloudmgr object.
 * @description Retrieves all the users(cloudmgrs) based on user type(cloudmgr) and CSPId
 */
exports.getAllcloudmgrsByCSPId = async function(networkObj, CSPId) {
  // Get the User from the identity context
  const users = networkObj.gateway.identityContext.user;
  let caClient;
  const result = [];
  try {
    // TODO: Must be handled in a config file instead of using if
    if (CSPId === 1) {
      const ccp = buildCCPCSP1();
      caClient = buildCAClient(FabricCAServices, ccp, 'ca.CSP1.cloud.com');
    } else if (CSPId === 2) {
      const ccp = buildCCPCSP2();
      caClient = buildCAClient(FabricCAServices, ccp, 'ca.CSP2.cloud.com');
    } else if (CSPId === 3) {
      const ccp = buildCCPCSP3();
      caClient = buildCAClient(FabricCAServices, ccp, 'ca.CSP3.cloud.com');
    }

    // Use the identity service to get the user enrolled using the respective CA
    const idService = caClient.newIdentityService();
    const userList = await idService.getAll(users);

    // for all identities the attrs can be found
    const identities = userList.result.identities;

    for (let i = 0; i < identities.length; i++) {
      tmp = {};
      if (identities[i].type === 'client') {
        tmp.id = identities[i].id;
        tmp.role = identities[i].type;
        attributes = identities[i].attrs;
        // cloudmgr object will consist of firstName and lastName
        for (let j = 0; j < attributes.length; j++) {
          if (attributes[j].name.endsWith('Name') || attributes[j].name === 'role' || attributes[j].name === 'speciality') {
            tmp[attributes[j].name] = attributes[j].value;
          }
        }
        result.push(tmp);
      }
    }
  } catch (error) {
    console.error(`Unable to get all cloudmgrs : ${error}`);
    const response = {};
    response.error = error;
    return response;
  }
  return result.filter(
    function(result) {
      return result.role === 'cloudmgr';
    },
  );
};
