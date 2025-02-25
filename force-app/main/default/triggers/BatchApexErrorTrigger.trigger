trigger BatchApexErrorTrigger on BatchApexErrorEvent (after insert) {
    Set<Id> asyncApexJobIds = new Set<Id>();
    for(BatchApexErrorEvent evt : Trigger.new){
        asyncApexJobIds.add(evt.AsyncApexJobId);
    }
    
    Map<Id,AsyncApexJob> jobs = new Map<Id,AsyncApexJob>(
        [SELECT id, ApexClass.Name FROM AsyncApexJob WHERE Id IN :asyncApexJobIds]
    );
    
    List<Batch_Log__c> errorsList = new List<Batch_Log__c>();
    for(BatchApexErrorEvent evt : Trigger.new){
        errorsList.add(new Batch_Log__c(Apex_Job_Id__c = evt.AsyncApexJobId, 
                                        Exception_Message__c = evt.Message, 
                                        Job_Scope__c = evt.JobScope, 
                                        Log_Type__c = evt.ExceptionType, 
                                        Entry_Date__c = Date.today(),
                                        Batch__c = jobs.get(evt.AsyncApexJobId).ApexClass.Name));
        
    }
    insert errorsList;
}