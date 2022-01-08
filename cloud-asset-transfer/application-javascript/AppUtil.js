/**
 * @author Ruks
 * @email ruks@hotmail.com
 * @create date 2021-12-26 13:26:42
 * @modify date 2021-12-28 11:08:40
 * @desc Referenced from https://github.com/hyperledger/fabric-samples/tree/master/test-application/javascript
 */

const fs = require('fs');
const path = require('path');

/**
 * @author Ruks
 * @return {ccp} ccp
 * @description Creates a connection profile and returns the network config to CSP 1. Reads the JSON file created
 * @description When CA is created there is a json for each CSP which specfies the connection profile.
 */
exports.buildCCPCSP1 = () => {
  // load the common connection configuration file
  const ccpPath = path.resolve(__dirname, '..', '..', 'cloud-network',
    'organizations', 'peerOrganizations', 'CSP1.cloud.com', 'connection-CSP1.json');
  const fileExists = fs.existsSync(ccpPath);
  if (!fileExists) {
    throw new Error(`no such file or directory: ${ccpPath}`);
  }
  const contents = fs.readFileSync(ccpPath, 'utf8');

  // build a JSON object from the file contents
  const ccp = JSON.parse(contents);

  console.log(`Loaded the network configuration located at ${ccpPath}`);
  return ccp;
};

/**
 * @author Ruks
 * @return {ccp} ccp
 * @description Creates a connection profile and returns the network config to CSP 2. Reads the JSON file created
 * @description When CA is created there is a json for each CSP which specfies the connection profile.
 */
exports.buildCCPCSP2 = () => {
  // load the common connection configuration file
  const ccpPath = path.resolve(__dirname, '..', '..', 'cloud-network',
    'organizations', 'peerOrganizations', 'CSP2.cloud.com', 'connection-CSP2.json');
  const fileExists = fs.existsSync(ccpPath);
  if (!fileExists) {
    throw new Error(`no such file or directory: ${ccpPath}`);
  }
  const contents = fs.readFileSync(ccpPath, 'utf8');

  // build a JSON object from the file contents
  const ccp = JSON.parse(contents);

  console.log(`Loaded the network configuration located at ${ccpPath}`);
  return ccp;
};

/**
 * @author Ruks
 * @return {ccp} ccp
 * @description Creates a connection profile and returns the network config to CSP 3. Reads the JSON file created
 * @description When CA is created there is a json for each CSP which specfies the connection profile.
 */
exports.buildCCPCSP3 = () => {
  // load the common connection configuration file
  const ccpPath = path.resolve(__dirname, '..', '..', 'cloud-network',
    'organizations', 'peerOrganizations', 'CSP3.cloud.com', 'connection-CSP3.json');
  const fileExists = fs.existsSync(ccpPath);
  if (!fileExists) {
    throw new Error(`no such file or directory: ${ccpPath}`);
  }
  const contents = fs.readFileSync(ccpPath, 'utf8');

  // build a JSON object from the file contents
  const ccp = JSON.parse(contents);

  console.log(`Loaded the network configuration located at ${ccpPath}`);
  return ccp;
};

/**
 * @author Ruks
 * @param  {*} Wallets
 * @param  {string} walletPath
 * @return {wallet} wallet
 * @description If there is no wallet presents, a new wallet is created else , returns the wallet that is present.
 * @description The wallet path is in ./cloud-applcation/server/src/network/wallet
 */
exports.buildWallet = async (Wallets, walletPath) => {
  // Create a new  wallet : Note that wallet is for managing identities.
  let wallet;
  if (walletPath) {
    wallet = await Wallets.newFileSystemWallet(walletPath);
    console.log(`Built a file system wallet at ${walletPath}`);
  } else {
    wallet = await Wallets.newInMemoryWallet();
    console.log('Built an in memory wallet');
  }

  return wallet;
};

/**
 * @author Ruks
 * @param  {string} inputString
 * @return {string} jsonString
 * @description Formats the string to JSON
 */
exports.prettyJSONString = (inputString) => {
  if (inputString) {
    return JSON.stringify(JSON.parse(inputString), null, 2);
  } else {
    return inputString;
  }
};
