public with sharing class HTTPRequestUtility {
    public static Boolean isGood(HttpResponse res) {
        Integer status = res.getStatusCode();
        return status >= 200 && status < 300;
    }
}