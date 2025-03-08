public with sharing class BatchTrackerController {
    public BatchTrackerController() {
    }

    @AuraEnabled(cacheable=true)
    public static List<LWCUtility.Field> getBatchesInSystem() {
        List<LWCUtility.Field> batchesList = new List<LWCUtility.Field>();
        //For this solution to work, each batch class has to implement de default constructor
        for (ApexClass c : [SELECT Name FROM ApexClass]) {
            try {
                System.Type t = system.type.forname(c.Name);
                if (t != null && t.newInstance() instanceof Database.Batchable<sObject>) {
                    batchesList.add(new LWCUtility.Field(t.getName(), t.getName()));
                }
            } catch (exception e) {
            }
        }
        System.debug('list batches: ' + batchesList);
        return batchesList;
    }
    @AuraEnabled
    public static List<Batch_Tracker__c> getBatchTrackersList() {
        return [
            SELECT Id, Name, Start_Date_Field__c, End_Date_Field__c, Record_Identifier_Field__c, Active__c
            FROM Batch_Tracker__c
            LIMIT 5000
        ];
    }
}