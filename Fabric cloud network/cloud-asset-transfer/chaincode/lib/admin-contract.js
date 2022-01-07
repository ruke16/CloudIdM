/**
 * @author Ruks
 * @email ruks@hotmail.com
 * @create date 2021-12-23 21:50:38
 * @modify date 2021-12-29 13:30:00
 * @desc [Admin Smartcontract to create, read cloud details in legder]
 */
/*
 * SPDX-License-Identifier: Apache-2.0
 */
'use strict';

let cloud = require('./cloud.js');
const PrimaryContract = require('./primary-contract.js');

class AdminContract extends PrimaryContract {

    //Returns the last cloudId in the set
    async getLatestcloudId(ctx) {
        let allResults = await this.queryAllclouds(ctx);

        return allResults[allResults.length - 1].cloudId;
    }

    //Create cloud in the ledger
    async createcloud(ctx, args) {
        args = JSON.parse(args);

        if (args.password === null || args.password === '') {
            throw new Error(`Empty or null values should not be passed for password parameter`);
        }

        let newcloud = await new cloud(args.cloudId, args.firstName, args.lastName, args.password, args.age,
            args.phoneNumber, args.emergPhoneNumber, args.address, args.bloodGroup, args.changedBy, args.allergies);
        const exists = await this.cloudExists(ctx, newcloud.cloudId);
        if (exists) {
            throw new Error(`The cloud ${newcloud.cloudId} already exists`);
        }
        const buffer = Buffer.from(JSON.stringify(newcloud));
        await ctx.stub.putState(newcloud.cloudId, buffer);
    }

    //Read cloud details based on cloudId
    async readcloud(ctx, cloudId) {
        let asset = await super.readcloud(ctx, cloudId)

        asset = ({
            cloudId: cloudId,
            firstName: asset.firstName,
            lastName: asset.lastName,
            phoneNumber: asset.phoneNumber,
            emergPhoneNumber: asset.emergPhoneNumber
        });
        return asset;
    }

    //Delete cloud from the ledger based on cloudId
    async deletecloud(ctx, cloudId) {
        const exists = await this.cloudExists(ctx, cloudId);
        if (!exists) {
            throw new Error(`The cloud ${cloudId} does not exist`);
        }
        await ctx.stub.deleteState(cloudId);
    }

    //Read clouds based on lastname
    async querycloudsByLastName(ctx, lastName) {
        let queryString = {};
        queryString.selector = {};
        queryString.selector.docType = 'cloud';
        queryString.selector.lastName = lastName;
        const buffer = await this.getQueryResultForQueryString(ctx, JSON.stringify(queryString));
        let asset = JSON.parse(buffer.toString());

        return this.fetchLimitedFields(asset);
    }

    //Read clouds based on firstName
    async querycloudsByFirstName(ctx, firstName) {
        let queryString = {};
        queryString.selector = {};
        queryString.selector.docType = 'cloud';
        queryString.selector.firstName = firstName;
        const buffer = await this.getQueryResultForQueryString(ctx, JSON.stringify(queryString));
        let asset = JSON.parse(buffer.toString());

        return this.fetchLimitedFields(asset);
    }

    //Retrieves all clouds details
    async queryAllclouds(ctx) {
        let resultsIterator = await ctx.stub.getStateByRange('', '');
        let asset = await this.getAllcloudResults(resultsIterator, false);

        return this.fetchLimitedFields(asset);
    }

    fetchLimitedFields = asset => {
        for (let i = 0; i < asset.length; i++) {
            const obj = asset[i];
            asset[i] = {
                cloudId: obj.Key,
                firstName: obj.Record.firstName,
                lastName: obj.Record.lastName,
                phoneNumber: obj.Record.phoneNumber,
                emergPhoneNumber: obj.Record.emergPhoneNumber
            };
        }

        return asset;
    }
}
module.exports = AdminContract;