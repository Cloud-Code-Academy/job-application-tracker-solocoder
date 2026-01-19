public with sharing class JobApplicationHelper {
    public static void setPrimaryContacts(List<Job__c> jobRecords) {
        List<Job__c> jobRecordsToUpdate = new List<Job__c>();
        // set the primary contact on Job record
        jobRecords = [SELECT Id, Company__c, Company__r.Name, Primary_Contact__c
                      FROM Job__c
                      WHERE Primary_Contact__c = null
                      WITH SECURITY_ENFORCED];
        // get set of account ids where primary contact is null
        Set<Id> companyAcctIds = new Set<Id>();
        for (Job__c jobs : jobRecords) {
            companyAcctIds.add(jobs.Company__c);
        }
        // map contacts to accounts
        Map<Id, Id> accountIdToContactId = new Map<Id, Id>();
        for (Contact cont : [SELECT Id, FirstName, LastName, AccountId, Level__c, RecordTypeId
                            FROM Contact
                            WHERE AccountId IN :companyAcctIds
                            AND RecordType.DeveloperName = 'General'
                            WITH SECURITY_ENFORCED])
            {
                if (!accountIdToContactId.containsKey(cont.AccountId)) {
                    accountIdToContactId.put(cont.AccountId, cont.Id);
                }
            }
        // assign the primary contact to job based on AccountId
        for (Job__c jobContact : jobRecords) {
            if (jobContact.Company__c != null && accountIdToContactId.containsKey(jobContact.Company__c)) {
            Id contactIdToAssign = accountIdToContactId.get(jobContact.Company__c);
            jobContact.Primary_Contact__c = contactIdToAssign;
            jobRecordsToUpdate.add(jobContact);
            }
        }
        Database.update(jobRecordsToUpdate, AccessLevel.USER_MODE);
    }
}