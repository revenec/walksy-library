public with sharing class OAuth2Utility {
    
     public static String getOAuth2Token(String endPoint, String client_id, String client_secret, String scope) {
        String jwt = createJWT(client_id, endPoint, client_secret, scope);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        String body = 'grant_type=' + EncodingUtil.urlEncode('urn:ietf:params:oauth:grant-type:jwt-bearer', 'UTF-8')
            + '&assertion=' + EncodingUtil.urlEncode(jwt, 'UTF-8');

        req.setBody(body);

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (HTTPRequestUtility.isGood(res)) {
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            return (String) result.get('access_token');
        } else {
            return 'Token was not created';
        }
    }

    public static String createJWT(String client_id, String endPoint, String client_secret, String scope) {

        Long iat = DateTime.now().getTime() / 1000;
        Long exp = iat + 3600;

        Map<String, Object> header = new Map<String, Object>();
        header.put('alg', 'RS256');
        header.put('typ', 'JWT');

        Map<String, Object> claims = new Map<String, Object>();
        claims.put('iss', client_id);
        claims.put('scope', scope);
        claims.put('aud', endPoint);
        claims.put('iat', iat);
        claims.put('exp', exp);

        String jwtHeader = EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(header))).replace('+', '-').replace('/', '_').replace('=', '');
        String jwtClaims = EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(claims))).replace('+', '-').replace('/', '_').replace('=', '');

        String jwtSignatureInput = jwtHeader + '.' + jwtClaims;
        
        Blob privateKeyBlob = EncodingUtil.base64Decode(client_secret);

        Blob signature = Test.isRunningTest() == false ? Crypto.sign('RSA-SHA256', Blob.valueOf(jwtSignatureInput), privateKeyBlob) : privateKeyBlob;

        String jwtSignature = EncodingUtil.base64Encode(signature).replace('+', '-').replace('/', '_').replace('=', '');

        return jwtSignatureInput + '.' + jwtSignature;
    }
}