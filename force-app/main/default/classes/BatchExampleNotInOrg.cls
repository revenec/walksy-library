public with sharing class BatchExampleNotInOrg implements Database.Batchable<sObject>, Database.RaisesPlatformEvents {
    
     public BatchExample(){}

     public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id FROM Account');   
     }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
               
    }


    public void finish(Database.BatchableContext bc) {
    
    }
}