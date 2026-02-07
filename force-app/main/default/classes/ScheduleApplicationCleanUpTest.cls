@IsTest
public with sharing class ScheduleApplicationCleanUpTest {
    @TestSetup
    static void setupTestData(){
        List<Tax_Rate__C> taxRates = new List<Tax_Rate__c>();
        taxRates.add(new Tax_Rate__c(Tax_Rate_Type__c = 'Federal', Bracket_Min__c = 0, Bracket_Max__c = 11925, Tax_Rate__c = 10));
        taxRates.add(new Tax_Rate__c(Tax_Rate_Type__c = 'Federal', Bracket_Min__c = 11926, Bracket_Max__c = 48475, Tax_Rate__c = 12));
        taxRates.add(new Tax_Rate__c(Tax_Rate_Type__c = 'Federal', Bracket_Min__c = 48476, Bracket_Max__c = 103350, Tax_Rate__c = 22));
        taxRates.add(new Tax_Rate__c(Tax_Rate_Type__c = 'Federal', Bracket_Min__c = 103351, Bracket_Max__c = 197300, Tax_Rate__c = 24));
        taxRates.add(new Tax_Rate__c(Tax_Rate_Type__c = 'Federal', Bracket_Min__c = 197301, Bracket_Max__c = 250525, Tax_Rate__c = 32));
        taxRates.add(new Tax_Rate__c(Tax_Rate_Type__c = 'Federal', Bracket_Min__c = 250526, Bracket_Max__c = 626350, Tax_Rate__c = 35));
        taxRates.add(new Tax_Rate__c(Tax_Rate_Type__c = 'Federal', Bracket_Min__c = 626351, Bracket_Max__c = 999999, Tax_Rate__c = 37));
        taxRates.add(new Tax_Rate__c(Tax_Rate_Type__c = 'Medicare', Medicare_Threshold_Amount__c = 200000, Additional_Medicare_Tax_Rate__c = .90, Tax_Rate__c = 1.45));
        taxRates.add(new Tax_Rate__c(Tax_Rate_Type__c = 'Social Security', Social_Security_Wage_Limit__c = 176100, Tax_Rate__c = 6.2));
        insert taxRates;

        Account newAcc = new Account (Name = 'Jacks Consulting Firm');
        insert newAcc;

        Contact newCont = new Contact (LastName = 'Snuggles', Level__c = 'Primary', AccountId = newAcc.Id);
        insert newCont;

        Job__c newJob = new Job__c(Job_Description__c = 'Salesforce Developer II', Company__c = newAcc.Id);
        Job__c newJob1 = new Job__c(Job_Description__c = 'Salesforce Developer II', Company__c = newAcc.Id);
        Job__c newJob2 = new Job__c(Job_Description__c = 'Salesforce Developer II', Company__c = newAcc.Id);
        List<Job__c> jobsToInsert = new List<Job__c>{newJob, newJob1, newJob2};
        insert jobsToInsert;

        Contact newAppCont = new Contact (LastName = 'Bloom', RecordTypeId = '012fj000003jOMDAA2');
        Contact newAppCont1 = new Contact (LastName = 'Flora', RecordTypeId = '012fj000003jOMDAA2');
        Contact newAppCont2 = new Contact (LastName = 'Stella', RecordTypeId = '012fj000003jOMDAA2');
        Contact newAppCont3 = new Contact (LastName = 'Musa', RecordTypeId = '012fj000003jOMDAA2');
        List<Contact> contToInsert = new List<Contact>{newAppCont, newAppCont1, newAppCont2, newAppCont3};
        insert contToInsert;

        Application__c newApp = new Application__c (Applicant__c = newAppCont.Id, Job_Number__c = newJob.Id, Application_Status__c = 'Saved', Follow__c = Date.today().addDays(-32));
        Application__c newApp1 = new Application__c (Applicant__c = newAppCont3.Id, Job_Number__c = newJob2.Id, Application_Status__c = 'Applying', Follow__c = Date.today().addDays(-30));
        Application__c newApp2 = new Application__c (Applicant__c = newAppCont1.Id, Job_Number__c = newJob1.Id, Application_Status__c = 'Accepted', Follow__c = Date.today().addDays(-32));// this one should not update
        Application__c newApp3 = new Application__c(Applicant__c = newAppCont2.Id, Job_Number__c = newJob2.Id, Application_Status__c = '', Follow__c = Date.today().addDays(-45));
        Application__c newApp4 = new Application__c(Applicant__c = newAppCont3.Id, Job_Number__c = newJob1.Id, Application_Status__c = '', Follow__c = Date.today().addDays(-12));// this one should not update
        Application__c newApp5 = new Application__c(Applicant__c = newAppCont.Id, Job_Number__c = newJob1.Id, Application_Status__c = 'Interviewing', Follow__c = Date.today().addDays(-12));// this one should not update
        Application__c newApp6 = new Application__c(Applicant__c = newAppCont2.Id, Job_Number__c = newJob.Id, Application_Status__c = 'Negotiating', Follow__c = Date.today().addDays(-42));
        Application__c newApp7 = new Application__c(Applicant__c = newAppCont3.Id, Job_Number__c = newJob.Id, Application_Status__c = 'Closed', Follow__c = Date.today().addDays(-42));// this one should not update
        List<Application__c> appsToInsert = new List<Application__c>{newApp,newApp1,newApp2, newApp3, newApp4, newApp5, newApp6, newApp7};
        insert appsToInsert;
    }

    @IsTest
    public static void ScheduleApplicationCleanUpTest_Pos() {

        List<Application__c> apps = [SELECT Id, Application_Status__c 
                                      FROM Application__c];

        Test.startTest();
            ScheduleApplicationCleanUp schedulable = new ScheduleApplicationCleanUp();
            schedulable.execute(null);
        Test.stopTest();

        List<Application__c> processedApps = [SELECT Id, Notes__c, Application_Status__c
                                              FROM Application__c
                                              WHERE Application_Status__c = 'Closed'];
        
        System.assertEquals(5, processedApps.size(), 'There should have been 5 applications closed via the scheduled process');
    }
}