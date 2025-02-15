declare module "@salesforce/apex/BatchController.getBatchesList" {
  export default function getBatchesList(): Promise<any>;
}
declare module "@salesforce/apex/BatchController.getBatchDetails" {
  export default function getBatchDetails(param: {apexClass: any}): Promise<any>;
}
declare module "@salesforce/apex/BatchController.getBatchLog" {
  export default function getBatchLog(param: {apexClass: any}): Promise<any>;
}
declare module "@salesforce/apex/BatchController.runBatch" {
  export default function runBatch(param: {apexClass: any, startDate: any, endDate: any}): Promise<any>;
}
declare module "@salesforce/apex/BatchController.getBatchStatus" {
  export default function getBatchStatus(param: {batchId: any}): Promise<any>;
}
declare module "@salesforce/apex/BatchController.getBatchSettings" {
  export default function getBatchSettings(param: {apexClass: any}): Promise<any>;
}
