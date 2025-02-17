public with sharing class BatchTrackerController {
    public BatchTrackerController() {}

    @AuraEnabled(cacheable = true)
    public static List<LWCUtility.Field> getBatchesInSystem() {
        List<LWCUtility.Field> batchesList = new List<LWCUtility.Field>();
        //For this solution to work, each batch class has to implement de default constructor
        for(ApexClass c : [SELECT Name FROM ApexClass]) {
            try {
                System.Type t = system.type.forname(c.Name);
                if(t != null && t.newInstance() instanceOf Database.Batchable<sObject>) {
                    batchesList.add(new LWCUtility.Field(t.getName(), t.getName()));
                }
            } catch(exception e) { }
        }
        System.debug('list batches: ' + batchesList);
        return batchesList; 
    }
}