public virtual class AbstractBatchTracker implements IBatchTracker, Database.Batchable<sObject>, Database.RaisesPlatformEvents{
    
    public class BatchTrackerException extends Exception{}

    private String fields;
    private String objectName;
    private String filters;
    private String limits;

    public AbstractBatchTracker setFields(String fields){
        this.fields = fields;
        return this;
    }

    public AbstractBatchTracker setObjectName(String objectName){
        this.objectName = objectName;
        return this;
    }   

    public AbstractBatchTracker setFilters(String filters){
        this.filters = filters;
        return this;
    }

    public AbstractBatchTracker setLimits(String limits){
        this.limits = limits;
        return this;
    }
    
    public String createQuery(){

        if(String.isBlank(fields) || String.isBlank(objectName)) {
            throw new BatchTrackerException('Not minim parameters provided fields: ' + fields + ' objectName: ' + objectName);
        }
        return 'SELECT ' + fields + 
               ' FROM ' + objectName + 
               (String.isNotBlank(filters) ? ' WHERE ' + filters : '') + 
               (String.isNotBlank(limits) ? ' LIMIT ' + limits : '');
    }

    public virtual void executeBatch(Database.BatchableContext bc, List<sObject> scope){}

    public virtual void executeFinish(Database.BatchableContext bc){}

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = createQuery();

        return Database.getQueryLocator(query);   
     }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
         executeBatch(bc, scope);     
    }


    public void finish(Database.BatchableContext bc) {
        executeFinish(bc);
    }
}