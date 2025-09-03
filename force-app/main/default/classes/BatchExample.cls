public with sharing class BatchExample extends AbstractBatchTracker {
    
    public override void executeBatch(Database.BatchableContext bc, List<sObject> scope){
        List<Account> accounts = (List<Account>) scope;
        for(Account acc : accounts){
            acc.Name = acc.Name + ' - Batch ';
        }
        update accounts;
    
    }

    public override void executeFinish(Database.BatchableContext bc){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{ UserInfo.getUserEmail() });
        mail.setSubject('Test message batch' + DateTime.now());
        mail.setHtmlBody('Batched has finished');

        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        mailList.add(mail);

        Messaging.SendEmailResult[] results = Messaging.sendEmail(mailList);
    }

}