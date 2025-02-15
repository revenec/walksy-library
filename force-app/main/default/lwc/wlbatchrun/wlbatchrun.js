import { LightningElement, track, api } from "lwc";
import runBatch from "@salesforce/apex/BatchController.runBatch";
import getBatchStatus from "@salesforce/apex/BatchController.getBatchStatus";

export default class wlbatchrun extends LightningElement {
    @track name;
    @track classname;

    @track minDate;
    @track maxDate;
    @track startDate;
    @track endDate;

    @track showDetailsModal = false;
    @track showSpinner = false;
    @track showRunDetails = false;
    @track errorMessage = "";
    @track details = {};
    @track displayDates = true;

    batchId = "";
    refreshIntervalId = "";

    @api
    get jobRunning() {
        return this.batchId != "";
    }

    @api
    get showError() {
        return this.errorMessage != "";
    }

    @api
    showDialog(classname, showDates) {
        if (showDates) {
            let startDate = new Date();
            startDate.setDate(new Date().getDate() - 30);

            this.startDate = startDate.toISOString().substring(0, 10);
            this.minDate = startDate.toISOString().substring(0, 10);
            this.maxDate = new Date().toISOString().substring(0, 10);
            this.endDate = new Date().toISOString().substring(0, 10);
        }

        this.name = classname;
        this.classname = classname;
        this.showDetailsModal = true;
        this.errorMessage = "";
        this.displayDates = showDates;
    }

    handleRun() {
        this.showSpinner = true;
        this.showRunDetails = false;
        this.errorMessage = "";

        if (this.startDate > this.endDate) {
            this.errorMessage = "The start date can't be after the end date";
        } else {
            runBatch({ apexClass: this.classname, startDate: this.startDate, endDate: this.endDate })
                .then((result) => {
                    console.log("result", result);
                    this.batchId = result;
                    this.checkBatch();
                })
                .catch((err) => {
                    this.showSpinner = false;
                    this.showDetailsModal = true;
                    this.errorMessage = "Theres a problem running this batch, check the borwser console";
                    console.log(err);
                });
        }
    }

    handleStartDateChange(event) {
        this.startDate = event.target.value;
    }

    handleEndDateChange(event) {
        this.endDate = event.target.value;
    }

    checkBatch() {
        console.log("checkBatch ");

        if (this.batchId != "") {
            this.showRunDetails = true;
            this.refreshIntervalId = setInterval(() => {
                console.log("sending ", this.batchId, this.refreshIntervalId);
                getBatchStatus({ batchId: this.batchId })
                    .then((details) => {
                        this.details = details;
                        console.log("result", details);
                        if (details.Status == "Aborted" || details.Status == "Completed" || details.Status == "Failed") {
                            clearInterval(this.refreshIntervalId);
                            this.batchId = "";
                        }
                    })
                    .catch((err) => {
                        console.log(err);
                    });
            }, 5000);
        }
    }

    closeDetailsModal() {
        this.showDetailsModal = false;
        this.showRunDetails = false;
        this.details = {};
        console.log("closeDetailsModal ", this.refreshIntervalId);
        clearInterval(this.refreshIntervalId);
    }
}
