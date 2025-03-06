import { LightningElement, wire, track } from "lwc";

import getBatchesInSystem from "@salesforce/apex/BatchTrackerController.getBatchesInSystem";
import getBatchTrackers from "@salesforce/apex/BatchTrackerController.getBatchTrackersList";
import BATCH_TRACKER_OBJECT from "@salesforce/schema/Batch_Tracker__c";
import BATCH_TRACKER_NAME from "@salesforce/schema/Batch_Tracker__c.Name";
import BATCH_TRACKER_ACTIVE from "@salesforce/schema/Batch_Tracker__c.Active__c";
import BATCH_TRACKER_START_DATE from "@salesforce/schema/Batch_Tracker__c.Start_Date_Field__c";
import BATCH_TRACKER_END_DATE from "@salesforce/schema/Batch_Tracker__c.End_Date_Field__c";
import BATCH_TRACKER_RECORD_IDENTIFIER from "@salesforce/schema/Batch_Tracker__c.Record_Identifier_Field__c";
import { refreshApex } from "@salesforce/apex";
import toastMessage from "c/utils";

const columns = [
    { label: "Batch Name", fieldName: "Name", type: "text" },
    { label: "Active", fieldName: "Active__c", type: "text" },
    { label: "Start Date", fieldName: "Start_Date_Field__c", type: "text" },
    { label: "End Date", fieldName: "End_Date_Field__c", type: "text" },
    { label: "Record Identifier", fieldName: "Record_Identifier_Field__c", type: "text" }
];
export default class wlbatchtracker extends LightningElement {
    batchTrackerObject = BATCH_TRACKER_OBJECT;
    batchClassName = BATCH_TRACKER_NAME;
    batchStartDateField = BATCH_TRACKER_START_DATE;
    batchEndDateField = BATCH_TRACKER_END_DATE;
    batchActiveField = BATCH_TRACKER_ACTIVE;
    batchRecordIdentifier = BATCH_TRACKER_RECORD_IDENTIFIER;
    columns = columns;
    @track batchTrackerId = null;
    @track batchTrackersList = [];
    batchName = null;
    batchesInSystem = [];

    @wire(getBatchesInSystem)
    wiredLoadBatches({ data, error }) {
        // Error handling
        if (data) {
            this.batchesInSystem = data;
        } else if (error) {
            toastMessage(this, "error", "Error", error.body.message);
        }
    }

    loadBatchTrackers() {
        getBatchTrackers()
            .then((result) => {
                this.batchTrackersList = result;
            })
            .catch((error) => {
                this.error = error;
            });
    }

    handleChange(event) {
        console.log("test");
        this.batchName = event.detail.value;
    }

    handleSubmit(event) {
        event.preventDefault();
        try {
            const fields = event.detail.fields;
            fields.Name = this.batchName;
            this.template.querySelector("lightning-record-edit-form").submit(fields);
            this.handleReset();
            refreshApex(this.loadBatchTrackers);
        } catch (error) {
            toastMessage(this, "error", "Error", error.body.message);
        }
    }

    handleReset() {
        this.batchName = null;
        const inputFields = this.template.querySelectorAll("lightning-input-field");
        if (inputFields) {
            inputFields.forEach((field) => {
                field.reset();
            });
        }
    }
}
