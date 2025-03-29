import { LightningElement, track, api } from "lwc";
import getBatchLog from "@salesforce/apex/BatchController.getBatchLog";

const columns = [
    { label: "Date", fieldName: "PRX__Entry_Date__c", hideDefaultActions: true },
    { label: "Apex Method", fieldName: "PRX__Method__c", hideDefaultActions: true },
    { label: "Description", fieldName: "PRX__Description__c", hideDefaultActions: true },
    { label: "Message", fieldName: "PRX__Exception_Message__c", hideDefaultActions: true },
];

export default class wlbatchlogs extends LightningElement {
    @track name;

    @track logs = [];
    @track showDetailsModal = false;

    columns = columns;

    @api
    getBatchLog(classname) {
        this.name = classname;
        getBatchLog({ apexClass: classname })
            .then((result) => {
                console.log(result);

                this.logs = result;
                this.showDetailsModal = true;
            })
            .catch((err) => {
                console.log(err);
                this.handleError(err);
            });
    }

    handleError(error) {}

    closeDetailsModal() {
        this.showDetailsModal = false;
    }
}