import { LightningElement, wire, track } from 'lwc';

import getBatchesInSystem from "@salesforce/apex/BatchTrackerController.getBatchesInSystem";
import BATCH_TRACKER_OBJECT from '@salesforce/schema/Batch_Tracker__c';
import BATCH_TRACKER_NAME from '@salesforce/schema/Batch_Tracker__c.Name';
import BATCH_TRACKER_ACTIVE from '@salesforce/schema/Batch_Tracker__c.Active__c';
import BATCH_TRACKER_START_DATE from '@salesforce/schema/Batch_Tracker__c.Start_Date_Field__c';
import BATCH_TRACKER_END_DATE from '@salesforce/schema/Batch_Tracker__c.End_Date_Field__c';
import BATCH_TRACKER_RECORD_IDENTIFIER from '@salesforce/schema/Batch_Tracker__c.Record_Identifier_Field__c';

export default class wlbatchtracker extends LightningElement {
    
    batchTrackerObject = BATCH_TRACKER_OBJECT;
    batchClassName = BATCH_TRACKER_NAME;
    batchStartDateField = BATCH_TRACKER_START_DATE;
    batchEndDateField = BATCH_TRACKER_END_DATE;
    batchActiveField = BATCH_TRACKER_ACTIVE;
    batchRecordIdentifier = BATCH_TRACKER_RECORD_IDENTIFIER;
    @track batchTrackerId = null;
    batchName = null;
    batchesInSystem = [];

    @wire(getBatchesInSystem)
    wiredLoadBatches({ error, data }) {
    // Error handling
        if (data) {
            this.batchesInSystem = data;
        }
    }
    

    handleChange(event) {
        this.batchName = event.detail.value;
    }

    handleSubmit(event) {
        event.preventDefault();
        const fields = event.detail.fields;
        fields.Name = this.batchName;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
        this.handleReset();
    }

    handleReset() { 
        this.batchName = null;
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
    }
}