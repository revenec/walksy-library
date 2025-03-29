import { LightningElement, wire, track } from "lwc";
import { toastMessage } from "c/utils";
import getBatchesList from "@salesforce/apex/BatchController.getBatchesList";

const actions = [
    { label: "View Settings", name: "view_settings" },
    { label: "Run Batch", name: "run_batch" },
    { label: "View Last 7 Days", name: "view_batch" },
    { label: "View Logs", name: "view_logs" },
];

const batchesColumns = [
    {
        label: "Date",
        fieldName: "StatusDate",
        type: "date",
        sortable: "true",
        hideDefaultActions: true,
        typeAttributes: {
            day: "numeric",
            month: "short",
            year: "numeric",
            hour: "2-digit",
            minute: "2-digit",
            second: "2-digit",
            hour12: true,
        },
    },
    { label: "Name", fieldName: "ApexClass", sortable: "true", hideDefaultActions: true },
    { label: "Job Type", fieldName: "JobType", sortable: "true", hideDefaultActions: true },

    { label: "Status", fieldName: "Status", sortable: "true", hideDefaultActions: true },
    {
        type: "action",
        hideDefaultActions: true,
        typeAttributes: { rowActions: actions },
    },
];

export default class wlbatches extends LightningElement {
    error;
    stack;

    @track showSpinner;
    @track batches = [];
    @track sortBy = "StatusDate";
    @track sortDirection = "asc";

    batchesColumns = batchesColumns;

    @wire(getBatchesList)
    getBatchesList() {
        this.showSpinner = true;
        getBatchesList()
            .then((result) => {
                this.batches = result;
                this.showSpinner = false;
                this.sortData(this.sortBy, this.sortDirection);
            })
            .catch((err) => this.handleError(err));
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case "run_batch":
                this.handleRunBatch(row);
                break;

            case "view_batch":
                this.handleViewBatch(row);
                break;
            case "view_logs":
                this.handleViewLogs(row);
                break;
            case "view_settings":
                this.handleViewSettings(row);
                break;
            default:
        }
    }

    handleViewLogs(row) {
        var uiSection = this.refs.logs;
        uiSection.getBatchLog(row.ApexClass);
    }

    handleRunBatch(row) {
        var uiSection = this.refs.run;
        uiSection.showDialog(row.ApexClass, row.NeedsDates);
    }

    handleViewBatch(row) {
        var uiSection = this.refs.details;
        uiSection.getbatchdetails(row.ApexClass);
    }

    handleViewSettings(row) {
        var uiSection = this.refs.settings;
        uiSection.getBatchSettings(row.ApexClass);
    }

    handleRefresh() {
        this.getBatchesList();
    }

    //error handling
    handleError(error) {
        this.showSpinner = false;
        toastMessage(this,error, true);
    }

    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.batches));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === "asc" ? 1 : -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ""; // handling null values
            y = keyValue(y) ? keyValue(y) : "";
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.batches = parseData;
    }
}