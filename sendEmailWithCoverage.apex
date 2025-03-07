Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
mail.setToAddresses(new List<String>{ UserInfo.getUserEmail() });
mail.setSubject('Test Coverage for package created on: ' + DateTime.now());
mail.setHtmlBody('The package was created, here you have a csv file with the test data.');

List<Messaging.EmailFileAttachment> fileAttachments = new List<Messaging.EmailFileAttachment>();
Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
attachment.setFileName('test_covarage_' + DateTime.now() + '.csv');
attachment.setBody([SELECT VersionData FROM ContentVersion WHERE Title = 'testcoverage' ORDER BY CreatedDate DESC LIMIT 1]?.VersionData);
attachment.setContentType('text/csv');
fileAttachments.add(attachment);
mail.setFileAttachments(fileAttachments);

List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
mailList.add(mail);

Messaging.SendEmailResult[] results = Messaging.sendEmail(mailList);