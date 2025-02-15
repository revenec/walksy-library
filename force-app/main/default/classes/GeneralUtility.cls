public with sharing class GeneralUtility {
   
    public static string cleanString(string stringToClean) {
        string regexText = '[|?|&|||!|{|}|\\[|\\]|\\(|\\)|^|~|*|:|\"|\'|+|\\-]';
        stringToClean = stringToClean.replaceAll(regexText, '*');

        integer indexOfAsterix = stringToClean.indexof('*');
        return stringToClean;
    }

    public static String cleanNullValue(String value) {
        return value ?? '';
    }

    public static Boolean isJSON(String text) {
        Boolean isJSON = true;
        if(String.isBlank(text) || (text.startsWith('{') == false && text.startsWith('[') == false)) {
            return false;
        }
        
        try {
            JSON.deserializeUntyped(text);
        } catch (Exception e) {
            isJSON = false;
        }

        return isJSON;
    }

    public static Boolean isValidSalesforceId(String id) {
        if (String.isBlank(id)) {
            return false;
        }
        try {
            Id idValue = (Id) id;
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    public static boolean isSalesforceLookup(Schema.DescribeFieldResult sfField) {
        return sfField.getReferenceTo().isEmpty() == false;
    }
}