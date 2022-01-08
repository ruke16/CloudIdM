/**
 * @author Ruks
 * @email ruks@hotmail.com
 * @create date 2021-12-14 21:50:38
 * @modify date 2021-12-28 20:03:33
 * @desc [Smartcontract to read, update cloud details in legder]
 */
/*
 * SPDX-License-Identifier: Apache-2.0
 */
'use strict';

let cloud = require('./cloud.js');
const AdminContract = require('./admin-contract.js');
const PrimaryContract = require("./primary-contract.js");
const { Context } = require('fabric-contract-api');

class cloudmgrContract extends AdminContract {

    //Read cloud details based on cloudId
    async readcloud(ctx, cloudId) {

        let asset = await PrimaryContract.prototype.readcloud(ctx, cloudId)

        // Get the cloudmgrID, retrieves the id used to connect the network
        const cloudmgrId = await this.getClientId(ctx);
        // Check if cloudmgr has the permission to read the cloud
        const permissionArray = asset.permissionGranted;
        if(!permissionArray.includes(cloudmgrId)) {
            throw new Error(`The cloudmgr ${cloudmgrId} does not have permission to cloud ${cloudId}`);
        }
        asset = ({
            cloudId: cloudId,
            firstName: asset.firstName,
            lastName: asset.lastName,
            age: asset.age,
            bloodGroup: asset.bloodGroup,
            allergies: asset.allergies,
            symptoms: asset.symptoms,
            diagnosis: asset.diagnosis,
            treatment: asset.treatment,
            followUp: asset.followUp
        });
        return asset;
    }

    //This function is to update cloud medical details. This function should be called by only cloudmgr.
    async updatecloudMedicalDetails(ctx, args) {
        args = JSON.parse(args);
        let isDataChanged = false;
        let cloudId = args.cloudId;
        let newSymptoms = args.symptoms;
        let newDiagnosis = args.diagnosis;
        let newTreatment = args.treatment;
        let newFollowUp = args.followUp;
        let updatedBy = args.changedBy;

        const cloud = await PrimaryContract.prototype.readcloud(ctx, cloudId);

        if (newSymptoms !== null && newSymptoms !== '' && cloud.symptoms !== newSymptoms) {
            cloud.symptoms = newSymptoms;
            isDataChanged = true;
        }

        if (newDiagnosis !== null && newDiagnosis !== '' && cloud.diagnosis !== newDiagnosis) {
            cloud.diagnosis = newDiagnosis;
            isDataChanged = true;
        }

        if (newTreatment !== null && newTreatment !== '' && cloud.treatment !== newTreatment) {
            cloud.treatment = newTreatment;
            isDataChanged = true;
        }

        if (newFollowUp !== null && newFollowUp !== '' && cloud.followUp !== newFollowUp) {
            cloud.followUp = newFollowUp;
            isDataChanged = true;
        }

        if (updatedBy !== null && updatedBy !== '') {
            cloud.changedBy = updatedBy;
        }

        if (isDataChanged === false) return;

        const buffer = Buffer.from(JSON.stringify(cloud));
        await ctx.stub.putState(cloudId, buffer);
    }

    //Read clouds based on lastname
    async querycloudsByLastName(ctx, lastName) {
        return await super.querycloudsByLastName(ctx, lastName);
    }

    //Read clouds based on firstName
    async querycloudsByFirstName(ctx, firstName) {
        return await super.querycloudsByFirstName(ctx, firstName);
    }

    //Retrieves cloud medical history based on cloudId
    async getcloudHistory(ctx, cloudId) {
        let resultsIterator = await ctx.stub.getHistoryForKey(cloudId);
        let asset = await this.getAllcloudResults(resultsIterator, true);

        return this.fetchLimitedFields(asset, true);
    }

    //Retrieves all clouds details
    async queryAllclouds(ctx, cloudmgrId) {
        let resultsIterator = await ctx.stub.getStateByRange('', '');
        let asset = await this.getAllcloudResults(resultsIterator, false);
        const permissionedAssets = [];
        for (let i = 0; i < asset.length; i++) {
            const obj = asset[i];
            if ('permissionGranted' in obj.Record && obj.Record.permissionGranted.includes(cloudmgrId)) {
                permissionedAssets.push(asset[i]);
            }
        }

        return this.fetchLimitedFields(permissionedAssets);
    }

    fetchLimitedFields = (asset, includeTimeStamp = false) => {
        for (let i = 0; i < asset.length; i++) {
            const obj = asset[i];
            asset[i] = {
                cloudId: obj.Key,
                firstName: obj.Record.firstName,
                lastName: obj.Record.lastName,
                age: obj.Record.age,
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
     * @author Jathin Sreenivas
     * @param  {Context} ctx
     * @description Get the client used to connect to the network.
     */
    async getClientId(ctx) {
        const clientIdentity = ctx.clientIdentity.getID();
        // Ouput of the above - 'x509::/OU=client/CN=hosp1admin::/C=US/ST=North Carolina/L=Durham/O=hosp1.lithium.com/CN=ca.hosp1.lithium.com'
        let identity = clientIdentity.split('::');
        identity = identity[1].split('/')[2].split('=');
        return identity[1].toString('utf8');
    }
}
module.exports = cloudmgrContract;