import { LightningElement, track, api } from "lwc";
import getBatchSettings from "@salesforce/apex/BatchController.getBatchSettings";

export default class wlbatchsettings extends LightningElement {
    @track name;
    @track showDetailsModal = false;

    mapData = [];

    @api
    get showSettings() {
        return this.mapData.length > 0;
    }

    @api
    getBatchSettings(classname) {
        this.mapData = [];
        this.name = classname;
        this.showSettings = false;
        getBatchSettings({ apexClass: classname })
            .then((data) => {
                for (let key in data) {
                    this.mapData.push({ value: data[key], key: key });
                }
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
