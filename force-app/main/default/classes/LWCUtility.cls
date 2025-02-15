public with sharing class LWCUtility {
    
    public static AuraHandledException throwAuraException(String message) {
        message = GeneralUtility.cleanNullValue(message);
        AuraHandledException errorAura = new AuraHandledException(message);
        errorAura.setMessage(message);
        return errorAura;
    }

    @AuraEnabled
    public static String getObjectNameFromRecordId(String recordId) {
        String objectName = '';

        if (String.isBlank(recordId) == true || (String.isBlank(recordId) == false && recordId.length() != 18 && recordId.length() != 15)) {
            return objectName;
        }
        try {
            Id salesforceId = recordId.replaceAll('"', '');
            objectName = salesforceId.getSObjectType().getDescribe().getName();
        } catch (Exception e) {
            System.debug('Logging error: ' + e.getMessage());
        }
        return objectName;
    }
}