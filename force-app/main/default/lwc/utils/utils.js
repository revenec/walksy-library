import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { loadStyle } from "lightning/platformResourceLoader";

const toastMessage = (page, message, isError) => {
    const toast = new ShowToastEvent({
        title: isError ? "Error" : "Success",
        message: typeof message === "object" ? (message.status ? "Error code " + message.status + ": " : "") + message.body.message : message,
        variant: isError ? "error" : "success",
    });

    page.dispatchEvent(toast);
};

const toastMessageInfo = (page,message) => {
    const toast = new ShowToastEvent({
        title: "Info",
        message: message,
        variant: "info",
    });

    page.dispatchEvent(toast);
};

const loadCustomStyle = (page, staticResourceUrl) => {
    Promise.all([loadStyle(page, staticResourceUrl)])
        .then(() => {
            console.log("Upload success");
        })
        .catch((error) => {
            console.error(error);
        });
};

export { toastMessage, loadCustomStyle, toastMessageInfo };
