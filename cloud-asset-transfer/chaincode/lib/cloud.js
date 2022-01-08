/**
 * @author Ruks
 * @email ruks@hotmail.com
 * @create date 2021-12-04 19:06:47
 * @modify date 2021-12-28 19:06:47
 * @desc [The base cloud class]
 */
/*
 * SPDX-License-Identifier: Apache-2.0
 */

const crypto = require('crypto');

class cloud {

    constructor(cloudId, firstName, lastName, password, age, phoneNumber, emergPhoneNumber, address, bloodGroup,
        changedBy = '', allergies = '', symptoms = '', diagnosis = '', treatment = '', followUp = '')
    {
        this.cloudId = cloudId;
        this.firstName = firstName;
        this.lastName = lastName;
        this.password = crypto.createHash('sha256').update(password).digest('hex');
        this.age = age;
        this.phoneNumber = phoneNumber;
        this.emergPhoneNumber = emergPhoneNumber;
        this.address = address;
        this.bloodGroup = bloodGroup;
        this.changedBy = changedBy;
        this.allergies = allergies;
        this.symptoms = symptoms;
        this.diagnosis = diagnosis;
        this.treatment = treatment;
        this.followUp = followUp;
        this.pwdTemp = true;
        this.permissionGranted = [];
        return this;
    }
}
module.exports = cloud