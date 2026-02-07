/**
 * Job Helper
 */
public with sharing class JobHelper {
    /**
    * Assigns a primary contact to job records
    * @param jobRecords List of Job Records used to verify Primary Contact has been assigned.
    */
    public static void setPrimaryContacts(List<Job__c> jobRecords) {
        List<Job__c> jobRecordsToUpdate = new List<Job__c>();
        // set the primary contact on Job record
        List<Job__c> jobRecordsToProcess = [SELECT Id, Company__c, Company__r.Name, Primary_Contact__c
                                            FROM Job__c
                                            WHERE Primary_Contact__c = null
                                            WITH SECURITY_ENFORCED];
        // get set of account ids where primary contact is null
        Set<Id> companyAcctIds = new Set<Id>();
        if (!jobRecordsToProcess.isEmpty()) {
            for (Job__c jobs : jobRecordsToProcess) {
            companyAcctIds.add(jobs.Company__c);
            }
        }
        
        // map contacts to account. 
        Map<Id, Id> accountIdToContactId = new Map<Id, Id>();
        // First add any primary contacts to the map
        List<Contact> primaryContact = [SELECT Id, FirstName, LastName, AccountId, Level__c, RecordTypeId
                                        FROM Contact
                                        WHERE AccountId IN :companyAcctIds
                                        AND RecordType.DeveloperName = 'General'
                                        AND Level__c = 'Primary'
                                        WITH SECURITY_ENFORCED];
        
        if (!primaryContact.isEmpty()) {
            for (Contact primcont : primaryContact) {
                if (!accountIdToContactId.containsKey(primcont.AccountId)) {
                    accountIdToContactId.put(primcont.AccountId, primcont.Id);
                }
            }
        }

        // Next get any contacts that are not Primary to add to the map
        List<Contact> nonPrimaryCont = [SELECT Id, FirstName, LastName, AccountId, Level__c, RecordTypeId
                                        FROM Contact
                                        WHERE AccountId IN :companyAcctIds
                                        AND RecordType.DeveloperName = 'General'
                                        AND (Level__c != 'Primary' OR Level__c = null)
                                        WITH SECURITY_ENFORCED];
        if (!nonPrimaryCont.isEmpty()) {
            for (Contact cont : nonPrimaryCont) {
                if (!accountIdToContactId.containsKey(cont.AccountId)) {
                    accountIdToContactId.put(cont.AccountId, cont.Id);
                }
            }
        }
        
        // assign the primary contact to job based on AccountId
        for (Job__c jobContact : jobRecordsToProcess) {
            if (jobContact.Company__c != null && accountIdToContactId.containsKey(jobContact.Company__c)) {
            Id contactIdToAssign = accountIdToContactId.get(jobContact.Company__c);
            jobContact.Primary_Contact__c = contactIdToAssign;
            jobRecordsToUpdate.add(jobContact);
            }
        }
        if (!jobRecordsToUpdate.isEmpty()) {
            Database.update(jobRecordsToUpdate, AccessLevel.USER_MODE);
        }
    }

    /**
    * Sends criteria for job search to an external system https://jooble.org/api + apikey
    * If the callout is successful (HTTP 200), then Job records are created based on search criteria
    * Fields: Company_Name, Salary_Range, Job_Description, Job_Title, Job_Link, External_Id
    *
    * @param keyword to search for jobs eg. Salesforce Developer
    * @param location to search for jobs eg. Seattle, WA
    * @param page to get jobs on the specified page type from results
    * @param resultsOnPage number of jobs to be created in Job record
    * @param minSalary minimum salary for search type: integer
    */
    @AuraEnabled
    public static void getJobFromJooble(String keyword, String location, Integer page, Integer resultsOnPage, Integer minSalary) {
        String parm = '{"keywords": "' + keyword + '", "location": "' + location + '", "page": "' + page + '", "resultonpage": "' + resultsOnPage + '", "salary": "' + minSalary + '"}';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(' https://jooble.org/api/85165ee4-2fcb-4827-bbdc-9c34fbaf4061');
        req.setMethod('POST');
        req.setHeader('Content-type', 'application/json');
        req.setBody(parm);
        Http http = new Http();
        HttpResponse res = http.send(req);
        //System.debug('Response status code::: ' + res.getStatusCode());
        //System.debug('Json Body::: ' + res.getBody());

        if (res.getStatusCode() == 200) {
            JobHelper.createJobFromJson(res.getBody());
        }
    }

    /**
     * Creates job record(s) based on search criteria
     * @param jsonResponse the JSON string payload that represents the job(s)
     */
    @TestVisible
    private static void createJobFromJson(String jsonResponse) {
        List<Job__c> jobsToInsert = new List<Job__c>();
        List<Account> acct = [SELECT Id, Name FROM Account WHERE Name = 'Jooble' WITH SECURITY_ENFORCED];
        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);

        List<Object> jobs = (List<Object>) jsonMap.get('jobs');
        // create new Job from JSON response
        for (Object obj : jobs) {
            Map<String, Object> jobsFound = (Map<String, Object>) obj;

            Job__c job = new Job__c();
            job.Company__c = acct[0].Id;
            job.Salary_Range__c = (String) jobsFound.get('salary');
            job.Job_Description__c = (String) jobsFound.get ('snippet');
            job.Company_Name__c = (String) jobsFound.get('company');
            job.Job_Title__c = (String) jobsFound.get('title');
            job.Company_Location__c = (String) jobsFound.get('location');
            job.Job_Link__c = (String) jobsFound.get('link');
            job.Type__c =(String) jobsFound.get('type');
            job.External_Id__c = String.valueOf(jobsFound.get('id'));

            jobsToInsert.add(job);
        }
        // other option is to return the list and then call the insert instead of auto inserting the records
        if (!jobsToInsert.isEmpty()) {
            Database.insert(jobsToInsert, AccessLevel.USER_MODE);
        }
    }
    /**
     * This method should populat the starting salary from the salary range field
     * @param jobs list of jobs
     */
    public static void populateStartingSalary(List<Job__c> jobs) {
        List<Job__c> jobsToProcess = [SELECT Id, Salary_Range__c, Salary_Offered__c
                                      FROM Job__c
                                      WHERE Salary_Offered__c = null
                                      AND Salary_Range__c != null
                                      WITH SECURITY_ENFORCED];
        if (!jobsToProcess.isEmpty()) {
            for (Job__c j : jobsToProcess) {
            if (j.Salary_Range__c.containsAny('k')) {
                String range = j.Salary_Range__c.substringAfter('$').substringBefore('k');
                Decimal rangeInThousands = Decimal.valueOf(range);
                j.Salary_Offered__c = rangeInThousands*1000;
                //System.debug('Salary offered for this job::: ' + j.id + ': '+ j.Salary_Offered__c);
            }
            }
        }
        if (!jobsToProcess.isEmpty()) {
            Database.update(jobsToProcess, AccessLevel.USER_MODE);
        }
    }
}