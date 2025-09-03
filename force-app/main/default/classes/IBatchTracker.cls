public interface IBatchTracker {
    
    String createQuery();

    void executeBatch(Database.BatchableContext bc, List<sObject> scope);

    void executeFinish(Database.BatchableContext bc);

}