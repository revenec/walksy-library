public with sharing class SObjectUtility {
    
    public static sObject getSObject(String query) {
        sObject objectRecord = null;
        try {
            objectRecord = ((List<sObject>) Database.query(query)).get(0);
        } catch (Exception e) {
            System.debug('Error getting SObject from query: ' + e.getMessage());
        }
        return objectRecord;
    }

    public static Schema.SObjectType getObjectType(String objectAPIName) {
        try {
            return ((SObject) (Type.forName('Schema.' + objectAPIName)).newInstance()).getSObjectType();
        } catch (Exception e) {
            return null;
        }
    }

    public static Schema.DescribeSObjectResult getObjectDescribe(String objectAPIName) {
        if(string.isBlank(objectAPIName)) {
            return null;
        }

        try {
            return ((SObject) (Type.forName('Schema.' + objectAPIName)).newInstance()).getSObjectType().getDescribe();
        } catch (Exception e) {
            return null;
        }
    }

    public static String getQueryBase(List<String> fieldsList, String objectApiName) {
        String query = null;
        if (String.isBlank(objectApiName)) {
            return query;
        }
        query = ' SELECT ';
        if (fieldsList == null || fieldsList.isEmpty() == true) {
            Schema.DescribeSObjectResult result = getObjectDescribe(objectApiName);
            fieldsList = new List<String>(result.fields.getMap().keySet());
        }
        query += String.join(fieldsList, ', ');
        query += (' FROM ' + objectApiName);

        return query;
    }

    public static List<Schema.RecordTypeInfo> getAvailableRecordTypesByObject(String SFObject) {
        List<Schema.RecordTypeInfo> recordTypesList = new List<Schema.RecordTypeInfo>();
        try {
            // Get the default record type ID for the running user
            String defaultRecordTypeId = getDefaultRecordTypeId(SFObject);

            // Get the describe result for the object
            Schema.DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe().get(SFObject).getDescribe();

            for (Schema.RecordTypeInfo rt : objectDescribe.getRecordTypeInfos()) {
                if (rt.isAvailable() && rt.isActive() && includeMasterRecordType(rt)) {
                    recordTypesList.add(rt);
                }
            }

            // Move default record type to the top of the list
            if(String.isNotBlank(defaultRecordTypeId) && recordTypesList.size() > 1) {
                Integer defaultIndex = -1;
                for (Integer i = 0; i < recordTypesList.size(); i++) {
                    if (recordTypesList[i].getRecordTypeId() == defaultRecordTypeId) {
                        defaultIndex = i;
                        break;
                    }
                }
                if (defaultIndex != -1) {
                    // Move default record type to the top of the list
                    Schema.RecordTypeInfo defaultRecordType = recordTypesList.remove(defaultIndex);
                    recordTypesList.add(0, defaultRecordType);
                }
            }
        } catch (Exception e) {
            System.debug('Error message: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
        }

        return recordTypesList;
    }

    public static String getDefaultRecordTypeId(String SFObject) {
        Map<String, Schema.RecordTypeInfo> recordTypeMap = Schema.getGlobalDescribe().get(SFObject).getDescribe().getRecordTypeInfosByName();
        for (Schema.RecordTypeInfo rt : recordTypeMap.values()) {
            if (rt.isDefaultRecordTypeMapping()) {
                return rt.getRecordTypeId();
            }
        }
        return null;
    }

    public static Boolean includeMasterRecordType(Schema.RecordTypeInfo rt) {
        return Test.isRunningTest() ? true : rt.isMaster() == false;
    }

    public static String getFieldLabel(String apiFieldName, String objectApiName) {
        String label = '';

        if (String.isBlank(apiFieldName) == true) {
            return label;
        }

        try {
            Schema.DescribeSObjectResult selectedObject = getObjectDescribe(objectApiName);
            Map<String, Schema.SObjectField> mfields = selectedObject.fields.getMap();
            Schema.DescribeFieldResult fieldResult = mfields.get(apiFieldName).getDescribe();
            label = fieldResult.getLabel();
        } catch (Exception e) {
            label = e.getMessage();
        }

        return label;
    }
}