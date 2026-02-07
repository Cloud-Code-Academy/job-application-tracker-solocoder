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
        Account newAcc2 = new Account (Name = 'Jooble');
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

    @IsTest
    public static void getJobFromJooble_Pos() {
        List<Account> acct = new List<Account>{
            new Account (Name = 'Jooble')
        };
        insert acct;
        
        String keyword = 'Salesforce Developer';
        String location = 'Seattle, WA';
        Integer page = 1;
        Integer resultsOnPage = 1;
        Integer minSalary = 120000;

        Test.setMock(HttpCalloutMock.class, new MockGenerator());
        Test.startTest();
            JobHelper.getJobFromJooble(keyword, location, page, resultsOnPage, minSalary);
        Test.stopTest();

        List<Job__c> jobRecords = [SELECT Id FROM Job__c];

        System.assertEquals(1, jobRecords.size(), 'Records should have been created');
    }

    @IsTest
    public static void populateStartingSalary_Pos() {
        Account newAcc = new Account(Name = 'Apex Coders');
        insert newAcc;
        
        List<Job__c> newJobList = new List<Job__c>{
            new Job__c(Company__c = newAcc.Id, Salary_Range__c = '$1900 monthly'),
            new Job__c(Company__c = newAcc.Id, Salary_Range__c = '$150k - $210k')
        };
        insert newJobList;

        Test.startTest();
            JobHelper.populateStartingSalary(newJobList);
        Test.stopTest();

        List<Job__c> updatedJobs = [SELECT Id, Salary_Offered__c FROM Job__c];

        System.assertEquals(null, updatedJobs[0].Salary_Offered__c, 'The salary offered field should not have updated');
        System.assertEquals(150000, updatedJobs[1].Salary_Offered__c, 'The salary offered field did not update correctly');
    }
    @IsTest
    public static void populateStartingSalary_Neg() {
        Account testAcc = new Account(Name = 'My Test Account');
        insert testAcc;
        
        List<Job__c> newJobs= new List<Job__c>{
            //new Job__c(Company__c = testAcc.Id, Salary_Range__c = ''),
            //new Job__c(Company__c = testAcc.Id, Salary_Range__c = '$150k - $210k', Salary_Offered__c = 180000)
        };
        insert newJobs;

        Test.startTest();
            JobHelper.populateStartingSalary(newJobs);
        Test.stopTest();

        List<Job__c> updatedJobs = [SELECT Id, Salary_Offered__c FROM Job__c];

        System.assertEquals(0, updatedJobs.size(), 'There were no jobs to process');
        
    }
}