@IsTest
public with sharing class ApplicationHelper_Test {
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
    }

    @IsTest
    public static void calculateFederalTax_Pos() {
        Decimal taxAmount = ApplicationHelper.calculateFederalTax(125000);
        Assert.areEqual(22847.14, taxAmount, 'The returned value does not match');
    }

    @IsTest
    public static void calculateMedicareTax_Pos() {
        Decimal taxAmount = ApplicationHelper.calculateMedicareTax(125000);
        Decimal taxAmount2 = ApplicationHelper.calculateMedicareTax(210000);
        Assert.areEqual(1812.50, taxAmount, 'The returned value does not match');
        Assert.areEqual(3135, taxAmount2, 'The returned value does not match');
    }

    @IsTest
    public static void calculateSocialSecurityTax_Pos() {
        Decimal taxAmount = ApplicationHelper.calculateSocialSecurityTax(125000);
        Assert.areEqual(7750, taxAmount, 'The returned value does not match');
    }

    @IsTest
    public static void createTasksOnChangeStatus_Pos_Saved() {
        Account newAcc = new Account (Name = 'My Test Account');  
        insert newAcc;

        Contact newCont = new Contact (LastName = 'TestContact', Level__c = 'Primary', AccountId = newAcc.Id);
        insert newCont;

        Job__c newJob = new Job__c(Job_Description__c = 'Test Job Description', Company__c = newAcc.Id);
        insert newJob;

        Contact newAppCont = new Contact (LastName = 'ApplicantContact', RecordTypeId = '012fj000003jOMDAA2');
        insert newAppCont;

        Application__c newApp = new Application__c (
            Applicant__c = newAppCont.Id, 
            Job_Number__c = newJob.Id,
            Application_Status__c = ''
            );
        insert newApp;

        newApp.Application_Status__c = 'Saved';
        update newApp;

        Test.startTest();
        ApplicationHelper.createTasksForStatus(newApp);
        Test.stopTest();

        List<Task> tasksCreated = [SELECT Id, WhatId, Subject FROM Task];
        Set<String> expectedSubjects = new Set<String>{'Validate job alignment', 'Review skills for fit', 'Mark excitement level'};
        Set<String> actualSubjects = new Set<String>();
        for (Task t : tasksCreated) {
            actualSubjects.add(t.Subject);
        }
        
        Assert.areEqual(3, tasksCreated.size(), 'Should have created 3 tasks');
        Assert.areEqual(expectedSubjects, actualSubjects, 'Actual task subjects do not match expected subjects');
    }

    @IsTest
    public static void createTasksOnChangeStatus_Pos_Applying() {
        Account newAcc = new Account (Name = 'My Test Account');  
        insert newAcc;

        Contact newCont = new Contact (LastName = 'TestContact', Level__c = 'Primary', AccountId = newAcc.Id);
        insert newCont;

        Job__c newJob = new Job__c(Job_Description__c = 'Test Job Description', Company__c = newAcc.Id);
        insert newJob;

        Contact newAppCont = new Contact (LastName = 'ApplicantContact', RecordTypeId = '012fj000003jOMDAA2');
        insert newAppCont;

        Application__c newApp = new Application__c (
            Applicant__c = newAppCont.Id, 
            Job_Number__c = newJob.Id,
            Application_Status__c = ''
            );
        insert newApp;

        newApp.Application_Status__c = 'Applying';
        update newApp;

        Test.startTest();
        ApplicationHelper.createTasksForStatus(newApp);
        Test.stopTest();

        List<Task> tasksCreated = [SELECT Id, WhatId, Subject FROM Task];
        Set<String> expectedSubjects = new Set<String>{'Research - find someone who works at company', 'Set informal interview', 'Identify potential referrals', 'Customize achievements', 'Submit application to Company webiste'};
        Set<String> actualSubjects = new Set<String>();
        for (Task t : tasksCreated) {
            actualSubjects.add(t.Subject);
        }
        
        Assert.areEqual(5, tasksCreated.size(), 'Should have created 5 tasks');
        Assert.areEqual(expectedSubjects, actualSubjects, 'Actual task subjects do not match expected subjects');
    }

    @IsTest
    public static void createTasksOnChangeStatus_Pos_Applied() {
        Account newAcc = new Account (Name = 'My Test Account');  
        insert newAcc;

        Contact newCont = new Contact (LastName = 'TestContact', Level__c = 'Primary', AccountId = newAcc.Id);
        insert newCont;

        Job__c newJob = new Job__c(Job_Description__c = 'Test Job Description', Company__c = newAcc.Id);
        insert newJob;

        Contact newAppCont = new Contact (LastName = 'ApplicantContact', RecordTypeId = '012fj000003jOMDAA2');
        insert newAppCont;

        Application__c newApp = new Application__c (
            Applicant__c = newAppCont.Id, 
            Job_Number__c = newJob.Id,
            Application_Status__c = ''
            );
        insert newApp;

        newApp.Application_Status__c = 'Applied';
        update newApp;

        Test.startTest();
        ApplicationHelper.createTasksForStatus(newApp);
        Test.stopTest();

        List<Task> tasksCreated = [SELECT Id, WhatId, Subject FROM Task];
        Set<String> expectedSubjects = new Set<String>{'Reach out to hiring manager', 'Follow up on your application', 'Identify and save similar job opps', 'Set up weekly networking calls'};
        Set<String> actualSubjects = new Set<String>();
        for (Task t : tasksCreated) {
            actualSubjects.add(t.Subject);
        }
        
        Assert.areEqual(4, tasksCreated.size(), 'Should have created 4 tasks');
        Assert.areEqual(expectedSubjects, actualSubjects, 'Actual task subjects do not match expected subjects');
    }

    @IsTest
    public static void createTasksOnChangeStatus_Pos_Interviewing() {
        Account newAcc = new Account (Name = 'My Test Account');  
        insert newAcc;

        Contact newCont = new Contact (LastName = 'TestContact', Level__c = 'Primary', AccountId = newAcc.Id);
        insert newCont;

        Job__c newJob = new Job__c(Job_Description__c = 'Test Job Description', Company__c = newAcc.Id);
        insert newJob;

        Contact newAppCont = new Contact (LastName = 'ApplicantContact', RecordTypeId = '012fj000003jOMDAA2');
        insert newAppCont;

        Application__c newApp = new Application__c (
            Applicant__c = newAppCont.Id, 
            Job_Number__c = newJob.Id,
            Application_Status__c = ''
            );
        insert newApp;

        newApp.Application_Status__c = 'Interviewing';
        update newApp;

        Test.startTest();
        ApplicationHelper.createTasksForStatus(newApp);
        Test.stopTest();

        List<Task> tasksCreated = [SELECT Id, WhatId, Subject FROM Task];
        Set<String> expectedSubjects = new Set<String>{'Prepare elevator pitch', 'Practice interview questions', 'Research company and interviewers', 'Prepare for virtual interiew', 'Send Thank you emails'};
        Set<String> actualSubjects = new Set<String>();
        for (Task t : tasksCreated) {
            actualSubjects.add(t.Subject);
        }
        
        Assert.areEqual(5, tasksCreated.size(), 'Should have created 5 tasks');
        Assert.areEqual(expectedSubjects, actualSubjects, 'Actual task subjects do not match expected subjects');
    }

    @IsTest
    public static void createTasksOnChangeStatus_Pos_Negotiating() {
        Account newAcc = new Account (Name = 'My Test Account');  
        insert newAcc;

        Contact newCont = new Contact (LastName = 'TestContact', Level__c = 'Primary', AccountId = newAcc.Id);
        insert newCont;

        Job__c newJob = new Job__c(Job_Description__c = 'Test Job Description', Company__c = newAcc.Id);
        insert newJob;

        Contact newAppCont = new Contact (LastName = 'ApplicantContact', RecordTypeId = '012fj000003jOMDAA2');
        insert newAppCont;

        Application__c newApp = new Application__c (
            Applicant__c = newAppCont.Id, 
            Job_Number__c = newJob.Id,
            Application_Status__c = ''
            );
        insert newApp;

        newApp.Application_Status__c = 'Negotiating';
        update newApp;

        Test.startTest();
        ApplicationHelper.createTasksForStatus(newApp);
        Test.stopTest();

        List<Task> tasksCreated = [SELECT Id, WhatId, Subject FROM Task];
        Set<String> expectedSubjects = new Set<String>{'Salary research', 'Prepare your negotiation scripts', 'Evaluate your offer'};
        Set<String> actualSubjects = new Set<String>();
        for (Task t : tasksCreated) {
            actualSubjects.add(t.Subject);
        }
        
        Assert.areEqual(3, tasksCreated.size(), 'Should have created 3 tasks');
        Assert.areEqual(expectedSubjects, actualSubjects, 'Actual task subjects do not match expected subjects');
    }

    @IsTest
    public static void createTasksOnChangeStatus_Pos_Accepted() {
        Account newAcc = new Account (Name = 'My Test Account');  
        insert newAcc;

        Contact newCont = new Contact (LastName = 'TestContact', Level__c = 'Primary', AccountId = newAcc.Id);
        insert newCont;

        Job__c newJob = new Job__c(Job_Description__c = 'Test Job Description', Company__c = newAcc.Id);
        insert newJob;

        Contact newAppCont = new Contact (LastName = 'ApplicantContact', RecordTypeId = '012fj000003jOMDAA2');
        insert newAppCont;

        Application__c newApp = new Application__c (
            Applicant__c = newAppCont.Id, 
            Job_Number__c = newJob.Id,
            Application_Status__c = ''
            );
        insert newApp;

        newApp.Application_Status__c = 'Accepted';
        update newApp;

        Test.startTest();
        ApplicationHelper.createTasksForStatus(newApp);
        Test.stopTest();

        List<Task> tasksCreated = [SELECT Id, WhatId, Subject FROM Task];
        Set<String> expectedSubjects = new Set<String>{'Plan your resignation and recharge', 'Prepare for your first day of onboarding'};
        Set<String> actualSubjects = new Set<String>();
        for (Task t : tasksCreated) {
            actualSubjects.add(t.Subject);
        }
        
        Assert.areEqual(2, tasksCreated.size(), 'Should have created 2 tasks');
        Assert.areEqual(expectedSubjects, actualSubjects, 'Actual task subjects do not match expected subjects');
    }

    @IsTest
    public static void createTasksOnChangeStatus_Pos_Closed() {
        Account newAcc = new Account (Name = 'My Test Account');  
        insert newAcc;

        Contact newCont = new Contact (LastName = 'TestContact', Level__c = 'Primary', AccountId = newAcc.Id);
        insert newCont;

        Job__c newJob = new Job__c(Job_Description__c = 'Test Job Description', Company__c = newAcc.Id);
        insert newJob;

        Contact newAppCont = new Contact (LastName = 'ApplicantContact', RecordTypeId = '012fj000003jOMDAA2');
        insert newAppCont;

        Application__c newApp = new Application__c (
            Applicant__c = newAppCont.Id, 
            Job_Number__c = newJob.Id,
            Application_Status__c = ''
            );
        insert newApp;

        newApp.Application_Status__c = 'Closed';
        update newApp;

        Test.startTest();
        ApplicationHelper.createTasksForStatus(newApp);
        Test.stopTest();

        List<Task> tasksCreated = [SELECT Id, WhatId, Subject FROM Task];
        Set<String> expectedSubjects = new Set<String>{'Send a follow-up email to interviewer', 'Review your notes'};
        Set<String> actualSubjects = new Set<String>();
        for (Task t : tasksCreated) {
            actualSubjects.add(t.Subject);
        }
        
        Assert.areEqual(2, tasksCreated.size(), 'Should have created 2 tasks');
        Assert.areEqual(expectedSubjects, actualSubjects, 'Actual task subjects do not match expected subjects');
    }
}