import { LightningElement, track, api } from "lwc";
import getBatchDetails from "@salesforce/apex/BatchController.getBatchDetails";

const columns = [
    {
        label: "Date",
        fieldName: "CreatedDate",
        type: "date",
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
    { label: "Job Type", fieldName: "JobType", hideDefaultActions: true },
    { label: "Items Processed", fieldName: "JobItemsProcessed", hideDefaultActions: true },
    { label: "Number Of Errors", fieldName: "NumberOfErrors", hideDefaultActions: true },
    { label: "Total Job Items", fieldName: "TotalJobItems", hideDefaultActions: true },
    { label: "Status", fieldName: "Status", hideDefaultActions: true },
];

export default class wlbatchdetails extends LightningElement {
    @track name;
    @track details = [];
    @track showDetailsModal = false;

    columns = columns;

    @api
    getbatchdetails(classname) {
        this.name = classname;
        getBatchDetails({ apexClass: classname })
            .then((result) => {
                this.details = result;
                this.showDetailsModal = true;
            })
            .catch((err) => {
                console.log(err);
            });
    }

    closeDetailsModal() {
        this.showDetailsModal = false;
    }
}
