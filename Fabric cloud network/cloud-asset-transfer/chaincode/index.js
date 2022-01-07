/*
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const PrimaryContract = require('./lib/primary-contract.js');
const AdminContract = require('./lib/admin-contract.js');
const cloudContract = require('./lib/cloud-contract.js');
const CloudmgrContract = require('./lib/cloudmgr-contract.js');

module.exports.contracts = [ PrimaryContract, AdminContract, CloudmgrContract, cloudContract ];
