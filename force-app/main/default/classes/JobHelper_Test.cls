@IsTest
public with sharing class JobHelper_Test {

    @IsTest
    public static void setPrimaryContacts_Pos() {
        Account newAcc = new Account (Name = 'Apex Coders');
                insert newAcc;
        
        Contact newPrimaryCont = new Contact (LastName = 'Snuggles', Level__c = 'Primary', AccountId = newAcc.Id);
        Contact newSecondaryCont = new Contact (LastName = 'Giggles', Level__c = 'Secondary', AccountId = newAcc.Id);
        Contact newContact3 = new Contact(LastName = 'Smiles', AccountId = newAcc.Id);
        insert new List<Contact>{newPrimaryCont, newSecondaryCont, newContact3};

        List<Job__c > newJob2 = new List<Job__c>{
            new Job__c(Company__c = newAcc.Id, Job_Description__c = 'Test Description for job posting in test class.')
        };
        insert newJob2;
    

        Test.startTest();
            JobHelper.setPrimaryContacts(newJob2);
        Test.stopTest();

        List<Job__c> jobsPassed = [SELECT Id, Primary_Contact__c FROM Job__c];

        Assert.areEqual(newPrimaryCont.Id, jobsPassed[0].Primary_Contact__c, 'Incorrect Primary Contact Assigned');
    }
    @IsTest
    public static void setPrimaryContacts_ContInAcctNoPrimary() {
        Account newAcc = new Account (Name = 'Apex Coders');
        Account newAcc2 = new Account (Name = 'Awesome Account');
        insert new List<Account>{newAcc, newAcc2};
        
        Contact newPrimaryCont = new Contact (LastName = 'Snuggles', Level__c = 'Primary', AccountId = newAcc.Id);
        Contact newContact3 = new Contact(LastName = 'Smiles', AccountId = newAcc2.Id);
        Contact newSecondaryCont = new Contact (LastName = 'Giggles',  AccountId = newAcc2.Id);
        insert new List<Contact>{newPrimaryCont, newSecondaryCont, newContact3};

        List<Job__c > newJob2 = new List<Job__c>{
            new Job__c(Company__c = newAcc2.Id, Job_Description__c = 'Test Description for job posting in test class.')
        };
        insert newJob2;
    

        Test.startTest();
            JobHelper.setPrimaryContacts(newJob2);
        Test.stopTest();

        List<Job__c> jobsPassed = [SELECT Id, Primary_Contact__c FROM Job__c];

        Assert.areNotEqual(newPrimaryCont.Id, jobsPassed[0].Primary_Contact__c, 'Primary Contact of newPrimaryContact should not be assigned to Job. Job already has a Primary Contact assigned.');
        Assert.areEqual(newSecondaryCont.Id, jobsPassed[0].Primary_Contact__c, 'Primary Contact should be newSecondaryCont');
    }
}