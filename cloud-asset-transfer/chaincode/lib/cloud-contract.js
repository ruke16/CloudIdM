/**
 * @author Ruks
 * @email ruks@hotmail.com
 * @create date 2021-12-14 21:50:38
 * @modify date 2021-12-28 20:15:21
 * @desc [cloud Smartcontract to read, update and delete cloud details in legder]
 */
/*
 * SPDX-License-Identifier: Apache-2.0
 */
'use strict';

let cloud = require('./cloud.js');
const crypto = require('crypto');
const PrimaryContract = require('./primary-contract.js');
const { Context } = require('fabric-contract-api');

class cloudContract extends PrimaryContract {

    //Read cloud details based on cloudId
    async readcloud(ctx, cloudId) {
        return await super.readcloud(ctx, cloudId);
    }

    //Delete cloud from the ledger based on cloudId
    async deletecloud(ctx, cloudId) {
        const exists = await this.cloudExists(ctx, cloudId);
        if (!exists) {
            throw new Error(`The cloud ${cloudId} does not exist`);
        }
        await ctx.stub.deleteState(cloudId);
    }

    //This function is to update cloud personal details. This function should be called by cloud.
    async updatecloudPersonalDetails(ctx, args) {
        args = JSON.parse(args);
        let isDataChanged = false;
        let cloudId = args.cloudId;
        let newFirstname = args.firstName;
        let newLastName = args.lastName;
        let newAge = args.age;
        let updatedBy = args.changedBy;
        let newPhoneNumber = args.phoneNumber;
        let newEmergPhoneNumber = args.emergPhoneNumber;
        let newAddress = args.address;
        let newAllergies = args.allergies;

        const cloud = await this.readcloud(ctx, cloudId)
        if (newFirstname !== null && newFirstname !== '' && cloud.firstName !== newFirstname) {
            cloud.firstName = newFirstname;
            isDataChanged = true;
        }

        if (newLastName !== null && newLastName !== '' && cloud.lastName !== newLastName) {
            cloud.lastName = newLastName;
            isDataChanged = true;
        }

        if (newAge !== null && newAge !== '' && cloud.age !== newAge) {
            cloud.age = newAge;
            isDataChanged = true;
        }

        if (updatedBy !== null && updatedBy !== '') {
            cloud.changedBy = updatedBy;
        }

        if (newPhoneNumber !== null && newPhoneNumber !== '' && cloud.phoneNumber !== newPhoneNumber) {
            cloud.phoneNumber = newPhoneNumber;
            isDataChanged = true;
        }

        if (newEmergPhoneNumber !== null && newEmergPhoneNumber !== '' && cloud.emergPhoneNumber !== newEmergPhoneNumber) {
            cloud.emergPhoneNumber = newEmergPhoneNumber;
            isDataChanged = true;
        }

        if (newAddress !== null && newAddress !== '' && cloud.address !== newAddress) {
            cloud.address = newAddress;
            isDataChanged = true;
        }

        if (newAllergies !== null && newAllergies !== '' && cloud.allergies !== newAllergies) {
            cloud.allergies = newAllergies;
            isDataChanged = true;
        }

        if (isDataChanged === false) return;

        const buffer = Buffer.from(JSON.stringify(cloud));
        await ctx.stub.putState(cloudId, buffer);
    }

    //This function is to update cloud password. This function should be called by cloud.
    async updatecloudPassword(ctx, args) {
        args = JSON.parse(args);
        let cloudId = args.cloudId;
        let newPassword = args.newPassword;

        if (newPassword === null || newPassword === '') {
            throw new Error(`Empty or null values should not be passed for newPassword parameter`);
        }

        const cloud = await this.readcloud(ctx, cloudId);
        cloud.password = crypto.createHash('sha256').update(newPassword).digest('hex');
        if(cloud.pwdTemp){
            cloud.pwdTemp = false;
            cloud.changedBy = cloudId;
        }
        const buffer = Buffer.from(JSON.stringify(cloud));
        await ctx.stub.putState(cloudId, buffer);
    }

    //Returns the cloud's password
    async getcloudPassword(ctx, cloudId) {
        let cloud = await this.readcloud(ctx, cloudId);
        cloud = ({
            password: cloud.password,
            pwdTemp: cloud.pwdTemp})
        return cloud;
    }

    //Retrieves cloud medical history based on cloudId
    async getcloudHistory(ctx, cloudId) {
        let resultsIterator = await ctx.stub.getHistoryForKey(cloudId);
        let asset = await this.getAllcloudResults(resultsIterator, true);

        return this.fetchLimitedFields(asset, true);
    }

    fetchLimitedFields = (asset, includeTimeStamp = false) => {
        for (let i = 0; i < asset.length; i++) {
            const obj = asset[i];
            asset[i] = {
                cloudId: obj.Key,
                firstName: obj.Record.firstName,
                lastName: obj.Record.lastName,
                age: obj.Record.age,
                address: obj.Record.address,
                phoneNumber: obj.Record.phoneNumber,
                emergPhoneNumber: obj.Record.emergPhoneNumber,
                bloodGroup: obj.Record.bloodGroup,
                allergies: obj.Record.allergies,
                symptoms: obj.Record.symptoms,
                diagnosis: obj.Record.diagnosis,
                treatment: obj.Record.treatment,
                followUp: obj.Record.followUp
            };
            if (includeTimeStamp) {
                asset[i].changedBy = obj.Record.changedBy;
                asset[i].Timestamp = obj.Timestamp;
            }
        }

        return asset;
    };

    /**
     * @author Ruks
     * @param  {Context} ctx
     * @param  {JSON} args containing cloudId and cloudmgrId
     * @description Add the cloudmgr to the permissionGranted array
     */
    async grantAccessTocloudmgr(ctx, args) {
        args = JSON.parse(args);
        let cloudId = args.cloudId;
        let cloudmgrId = args.cloudmgrId;

        // Get the cloud asset from world state
        const cloud = await this.readcloud(ctx, cloudId);
        // unique cloudmgrIDs in permissionGranted
        if (!cloud.permissionGranted.includes(cloudmgrId)) {
            cloud.permissionGranted.push(cloudmgrId);
            cloud.changedBy = cloudId;
        }
        const buffer = Buffer.from(JSON.stringify(cloud));
        // Update the ledger with updated permissionGranted
        await ctx.stub.putState(cloudId, buffer);
    };

    /**
     * @author Jathin Sreenivas
     * @param  {Context} ctx
     * @param  {JSON} args containing cloudId and cloudmgrId
     * @description Remove the cloudmgr from the permissionGranted array
     */
    async revokeAccessFromcloudmgr(ctx, args) {
        args = JSON.parse(args);
        let cloudId = args.cloudId;
        let cloudmgrId = args.cloudmgrId;

        // Get the cloud asset from world state
        const cloud = await this.readcloud(ctx, cloudId);
        // Remove the cloudmgr if existing
        if (cloud.permissionGranted.includes(cloudmgrId)) {
            cloud.permissionGranted = cloud.permissionGranted.filter(cloudmgr => cloudmgr !== cloudmgrId);
            cloud.changedBy = cloudId;
        }
        const buffer = Buffer.from(JSON.stringify(cloud));
        // Update the ledger with updated permissionGranted
        await ctx.stub.putState(cloudId, buffer);
    };
}
module.exports = cloudContract;