public with sharing class BatchController {
    public BatchController() {}

    @AuraEnabled
    public static List<BatchInfo> getBatchesList() {
        Set<String> batchClasses = new Set<String>{
            'TransactionProcessingBatch',
            'TransactionLineProcessingBatch2',
            'TransactionEventProcessingBatch',
            'TasksCleanupBatch',
            'OutreachAttributionBatch',
            'LogProcessingBatch',
            'ItemConnectionProcessingBatch',
            'EventAttributionBatch'
        };
        Set<String> classNames = new Set<String>();
        for (ApexClass aClass : [SELECT Id, Name FROM ApexClass WHERE Name IN :batchClasses]) {
            classNames.add(aClass.Name);
        }

        DateTime sevenDaysAgo = System.now().addDays(-7);

        Map<String, BatchInfo> batches = new Map<String, BatchInfo>();

        for (AsyncApexJob job : [
            SELECT CreatedDate, ApexClass.Name, ApexClass.Namespaceprefix, Id, JobItemsProcessed, JobType, Status, NumberOfErrors, MethodName
            FROM AsyncApexJob
            WHERE ApexClass.Name IN :classNames AND CreatedDate > :sevenDaysAgo AND Status = 'Queued'
            ORDER BY CreatedDate DESC
        ]) {
            if (!batches.containsKey(job.ApexClass.Name)) {
                Batch batchClass = (Batch) Type.forName(job.ApexClass.Name).newInstance();
                Boolean needsDate = batchClass.needsDates();

                BatchInfo b = new BatchInfo(job.ApexClass.Name, job.status, needsDate, job.CreatedDate, job.JobType);
                batches.put(job.ApexClass.Name, b);
            }
        }

        for (AsyncApexJob job : [
            SELECT CreatedDate, ApexClass.Name, ApexClass.Namespaceprefix, Id, JobItemsProcessed, JobType, Status, NumberOfErrors, MethodName
            FROM AsyncApexJob
            WHERE ApexClass.Name IN :classNames AND CreatedDate > :sevenDaysAgo AND Status != 'Queued'
            ORDER BY CreatedDate DESC
        ]) {
            if (!batches.containsKey(job.ApexClass.Name)) {
                Batch batchClass = (Batch) Type.forName(job.ApexClass.Name).newInstance();
                Boolean needsDate = batchClass.needsDates();

                BatchInfo b = new BatchInfo(job.ApexClass.Name, job.status, needsDate, job.CreatedDate, job.JobType);
                batches.put(job.ApexClass.Name, b);
            }
        }

        System.Debug(batches.keySet());

        // Last bit is to make sure we cover all the possilbe classes, as the above will only return if it's scheduled, or has ran.
        for (String cls : classNames) {
            System.Debug(cls);

            if (!batches.containsKey(cls)) {
                BatchInfo b = new BatchInfo(cls, 'Unknown', false, System.Now(), 'Unknown');
                batches.put(cls, b);
            }
        }

        return batches.Values();
    }

    @AuraEnabled
    public static List<AsyncApexJob> getBatchDetails(string apexClass) {
        try {
            if (string.isBlank(apexClass)) {
                return null;
            }
            DateTime sevenDaysAgo = System.now().addDays(-7);

            String query =
                'SELECT CreatedDate, ApexClass.Name, ApexClass.Namespaceprefix, Id, JobItemsProcessed, JobType, Status, NumberOfErrors, MethodName ' +
                'FROM AsyncApexJob ' +
                'WHERE ApexClass.Name = :apexClass AND CreatedDate >: sevenDaysAgo ' +
                'ORDER BY CreatedDate Desc';

            return (List<AsyncApexJob>) Database.Query(query);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Batch_Log__c> getBatchLog(string apexClass) {
        System.Debug('getBatchLog ' + apexClass);

        try {
            if (string.isBlank(apexClass)) {
                return null;
            }
            DateTime sevenDaysAgo = SYstem.now().addDays(-7);

            String query =
                'SELECT Batch__c, Description__c, Entry_Date__c, Exception_Message__c, Method__c, Id ' +
                'FROM Batch_Log__c ' +
                'WHERE Class__c = :apexClass AND CreatedDate >: sevenDaysAgo ' +
                'ORDER BY CreatedDate desc';

            return (List<Batch_Log__c>) Database.Query(query);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=false)
    public static ID runBatch(string apexClass, Date startDate, Date endDate) {
        try {
            if (string.isBlank(apexClass)) {
                return null;
            }

            Batch batchClass = (Batch) Type.forName(apexClass).newInstance();

            return batchClass.runMe(startDate, endDate);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static AsyncApexJob getBatchStatus(String batchId) {
        try {
            return [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID = :batchId];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, String> getBatchSettings(string apexClass) {
        try {
            if (string.isBlank(apexClass)) {
                return null;
            }

            Batch batchClass = (Batch) Type.forName(apexClass).newInstance();

            return batchClass.getBatchSettings();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class BatchInfo {
        @AuraEnabled
        public String ApexClass { get; set; }
        @AuraEnabled
        public String Status { get; set; }
        @AuraEnabled
        public String JobType { get; set; }
        @AuraEnabled
        public Boolean NeedsDates { get; set; }
        @AuraEnabled
        public DateTime StatusDate { get; set; }

        public BatchInfo(String apexClass, String status, Boolean needsDates, DateTime statusDate, String jobType) {
            this.ApexClass = apexClass;
            this.Status = status;
            this.JobType = jobType;
            this.NeedsDates = needsDates;
            this.StatusDate = statusDate;
        }
    }

    public interface Batch {
        ID runMe(Date startDate, Date endDate);
        Boolean needsDates();

        Map<String, String> getBatchSettings();
    }
}