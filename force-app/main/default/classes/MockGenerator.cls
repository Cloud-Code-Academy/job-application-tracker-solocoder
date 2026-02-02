/**
 * Use this class to test HTTP callout
 */
global with sharing class MockGenerator implements HttpCalloutMock {
    global static string PAYLOAD = '{' + '"totalCount": 1,' + ' "jobs": [' + '{"salary": "120000", "snippet": "job description", "company": "Test Co", "title": "Salesforce Admin", "location": "Seattle, WA", "link": "https://developer.salesforce.com/","type": "full-time", "id": "789"}' + ']' + '}';
    global HTTPResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setBody(PAYLOAD);
        res.setStatusCode(200);
        res.setHeader('Content-type', 'application/json');
        return res;
    }
}