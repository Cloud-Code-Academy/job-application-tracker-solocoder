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

        Account newAcc = new Account (Name = 'Jacks Consulting Firm');
        insert newAcc;

        Contact newCont = new Contact (LastName = 'Snuggles', Level__c = 'Primary', AccountId = newAcc.Id);
        insert newCont;

        Job__c newJob = new Job__c(Job_Description__c = 'Salesforce Developer II', Company__c = newAcc.Id);
        insert newJob;

        Id recordTypeId = Schema.SObjectType.Contact
        .getRecordTypeInfosByName()
        .get('Applicant')
        .getRecordTypeId();
        Contact newAppCont = new Contact (LastName = 'Bloom', RecordTypeId = recordTypeId);
        insert newAppCont;

        Application__c newApp = new Application__c (
            Applicant__c = newAppCont.Id,
            Job_Number__c = newJob.Id,
            Application_Status__c = ''
            );
        insert newApp;
    }

    @IsTest
    public static void calculateFederalTax_Pos() {
        Decimal taxAmount = ApplicationHelper.calculateFederalTax(125000);
        Assert.areEqual(22847.14, taxAmount, 'The calculated Federal Tax Amount is incorrect');
    }

    @IsTest
    public static void calculateFederalTax_Neg() {
        Decimal taxAmount = ApplicationHelper.calculateFederalTax(250000);
        Assert.areNotEqual(587974, taxAmount, 'The calculated Federal Tax Amount is incorrect');
    }

    @IsTest
    public static void calculateMedicareTax_Pos() {
        Decimal taxAmount = ApplicationHelper.calculateMedicareTax(125000);
        Assert.areEqual(1812.50, taxAmount, 'The calculated Medicare Tax Amount is incorrect');
    }

    @IsTest
    public static void calculateMedicareTax_PosThres() {
        Decimal taxAmount2 = ApplicationHelper.calculateMedicareTax(210000);
        Assert.areEqual(3135, taxAmount2, 'The calculated Medicare Tax Amount is incorrect');
    }

    @IsTest
    public static void calculateMedicareTax_Neg() {
        Decimal taxAmount = ApplicationHelper.calculateMedicareTax(199000);
        Assert.areNotEqual(2800.00, taxAmount, 'The calculated Medicare Tax Amount is incorrect');
    }

    @IsTest
    public static void calculateMedicareTax_NegThres() {
        Decimal taxAmount2 = ApplicationHelper.calculateMedicareTax(220000);
        Assert.areNotEqual(3300, taxAmount2, 'The calculated Medicare Tax Amount is incorrect');
    }

    @IsTest
    public static void calculateSocialSecurityTax_Pos() {
        Decimal taxAmount = ApplicationHelper.calculateSocialSecurityTax(125000);
        Assert.areEqual(7750, taxAmount, 'The calculated Social Security Tax Amount is incorrect');
    }

    @IsTest
    public static void calculateSocialSecurityTax_Neg() {
        Decimal taxAmount = ApplicationHelper.calculateSocialSecurityTax(230000);
        Assert.areNotEqual(14260, taxAmount, 'The calculated Social Security Tax Amount is incorrect');
    }

    @IsTest
    public static void createTasksOnChangeStatus_Pos_Null() {
        Application__c newApp = [SELECT Id, Application_Status__c
                                 FROM Application__c
                                 LIMIT 1];

        newApp.Application_Status__c = '';
        update newApp;

        Test.startTest();
            ApplicationHelper.createTasksForStatus(newApp);
        Test.stopTest();

        List<Task> tasksCreated = [SELECT Id, WhatId, Subject FROM Task];
        //Set<String> expectedSubjects = new Set<String>{'Validate job alignments', 'Review skills for fit', 'Mark excitement level'};
        //Set<String> actualSubjects = new Set<String>();
        //for (Task t : tasksCreated) {
        //    actualSubjects.add(t.Subject);
        //}
        Assert.areEqual(0, tasksCreated.size(), 'Should NOT have created any tasks');
        //Assert.areNotEqual(expectedSubjects, actualSubjects, 'Actual task subjects do not match expected subjects');
    }
    
    @IsTest
    public static void createTasksOnChangeStatus_Neg_Null() {
        Application__c newApp = [SELECT Id, Application_Status__c
                                 FROM Application__c
                                 LIMIT 1];

        newApp.Application_Status__c = '';
        update newApp;

        Test.startTest();
            ApplicationHelper.createTasksForStatus(newApp);
        Test.stopTest();

        List<Task> tasksCreated = [SELECT Id, WhatId, Subject FROM Task];
        Set<String> expectedSubjects = new Set<String>{'Validate job alignments', 'Review skills for fit', 'Mark excitement level'};
        Set<String> actualSubjects = new Set<String>();
        for (Task t : tasksCreated) {
            actualSubjects.add(t.Subject);
        }
        Assert.areNotEqual(2, tasksCreated.size(), 'Should not have created 2 tasks');
        Assert.areNotEqual(expectedSubjects, actualSubjects, 'There Should be no tasks');
    }

    @IsTest
    public static void createTasksOnChangeStatus_Pos_Saved() {
        Application__c newApp = [SELECT Id, Application_Status__c
                                 FROM Application__c
                                 LIMIT 1];

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
    public static void createTasksOnChangeStatus_Neg_Saved() {
        Application__c newApp = [SELECT Id, Application_Status__c
                                 FROM Application__c
                                 LIMIT 1];

        newApp.Application_Status__c = 'Saved';
        update newApp;

        Test.startTest();
            ApplicationHelper.createTasksForStatus(newApp);
        Test.stopTest();

        List<Task> tasksCreated = [SELECT Id, WhatId, Subject FROM Task];
        Set<String> expectedSubjects = new Set<String>{'Validate job alignments', 'Review skills for fit', 'Mark excitement level'};
        Set<String> actualSubjects = new Set<String>();
        for (Task t : tasksCreated) {
            actualSubjects.add(t.Subject);
        }
        Assert.areNotEqual(2, tasksCreated.size(), 'Should NOT have created 2 tasks');
        Assert.areNotEqual(expectedSubjects, actualSubjects, 'Actual task subjects do match expected subjects');
    }
    

    @IsTest
    public static void createTasksOnChangeStatus_Pos_Applying() {
        Application__c newApp = [SELECT Id, Application_Status__c
                                 FROM Application__c
                                 LIMIT 1];

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
    public static void createTasksOnChangeStatus_Neg_Applying() {
        Application__c newApp = [SELECT Id, Application_Status__c
                                 FROM Application__c
                                 LIMIT 1];

        newApp.Application_Status__c = 'Applying';
        update newApp;

        Test.startTest();
            ApplicationHelper.createTasksForStatus(newApp);
        Test.stopTest();

        List<Task> tasksCreated = [SELECT Id, WhatId, Subject FROM Task];
        Set<String> expectedSubjects = new Set<String>{'Research - find someone who works at company', 'Set informal interview', 'Identify potential referrals', 'Customize achievement', 'Submit application to Company webiste'};
        Set<String> actualSubjects = new Set<String>();
        for (Task t : tasksCreated) {
            actualSubjects.add(t.Subject);
        }
        Assert.areNotEqual(3, tasksCreated.size(), 'Should not have created 3 tasks');
        Assert.areNotEqual(expectedSubjects, actualSubjects, 'Actual task subjects do match expected subjects');
    }

    @IsTest
    public static void createTasksOnChangeStatus_Pos_Applied() {
        Application__c newApp = [SELECT Id, Application_Status__c
                                 FROM Application__c
                                 LIMIT 1];

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
    public static void createTasksOnChangeStatus_Neg_Applied() {
        Application__c newApp = [SELECT Id, Application_Status__c
                                 FROM Application__c
                                 LIMIT 1];

        newApp.Application_Status__c = 'Applied';
        update newApp;

        Test.startTest();
            ApplicationHelper.createTasksForStatus(newApp);
        Test.stopTest();

        List<Task> tasksCreated = [SELECT Id, WhatId, Subject FROM Task];
        Set<String> expectedSubjects = new Set<String>{'Reach out to hiring managers', 'Follow up on your application', 'Identify and save similar job opps', 'Set up weekly networking calls'};
        Set<String> actualSubjects = new Set<String>();
        for (Task t : tasksCreated) {
            actualSubjects.add(t.Subject);
        }
        Assert.areNotEqual(3, tasksCreated.size(), 'Should not have created 3 tasks');
        Assert.areNotEqual(expectedSubjects, actualSubjects, 'Actual task subjects match expected subjects');
    }

    @IsTest
    public static void createTasksOnChangeStatus_Pos_Interviewing() {
        Application__c newApp = [SELECT Id, Application_Status__c
                                 FROM Application__c
                                 LIMIT 1];

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
    public static void createTasksOnChangeStatus_Neg_Interviewing() {
        Application__c newApp = [SELECT Id, Application_Status__c
                                 FROM Application__c
                                 LIMIT 1];

        newApp.Application_Status__c = 'Interviewing';
        update newApp;

        Test.startTest();
            ApplicationHelper.createTasksForStatus(newApp);
        Test.stopTest();

        List<Task> tasksCreated = [SELECT Id, WhatId, Subject FROM Task];
        Set<String> expectedSubjects = new Set<String>{'Prepare elevator pitch', 'Research company and interviewers', 'Prepare for virtual interiew', 'Send Thank you emails'};
        Set<String> actualSubjects = new Set<String>();
        for (Task t : tasksCreated) {
            actualSubjects.add(t.Subject);
        }
        Assert.areNotEqual(4, tasksCreated.size(), 'Should not have created 4 tasks');
        Assert.areNotEqual(expectedSubjects, actualSubjects, 'Actual task subjects match expected subjects');
    }

    @IsTest
    public static void createTasksOnChangeStatus_Pos_Negotiating() {
        Application__c newApp = [SELECT Id, Application_Status__c
                                 FROM Application__c
                                 LIMIT 1];

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
    public static void createTasksOnChangeStatus_Neg_Negotiating() {
        Application__c newApp = [SELECT Id, Application_Status__c
                                 FROM Application__c
                                 LIMIT 1];

        newApp.Application_Status__c = 'Negotiating';
        update newApp;

        Test.startTest();
            ApplicationHelper.createTasksForStatus(newApp);
        Test.stopTest();

        List<Task> tasksCreated = [SELECT Id, WhatId, Subject FROM Task];
        Set<String> expectedSubjects = new Set<String>{'Salary research for job', 'Prepare your negotiation scripts', 'Evaluate your offer'};
        Set<String> actualSubjects = new Set<String>();
        for (Task t : tasksCreated) {
            actualSubjects.add(t.Subject);
        }
        Assert.areNotEqual(1, tasksCreated.size(), 'Should Not have created 1 tasks');
        Assert.areNotEqual(expectedSubjects, actualSubjects, 'Actual task subjects do not match expected subjects');
    }

    @IsTest
    public static void createTasksOnChangeStatus_Pos_Accepted() {
        Application__c newApp = [SELECT Id, Application_Status__c
                                 FROM Application__c
                                 LIMIT 1];

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
    public static void createTasksOnChangeStatus_Neg_Accepted() {
        Application__c newApp = [SELECT Id, Application_Status__c
                                 FROM Application__c
                                 LIMIT 1];

        newApp.Application_Status__c = 'Accepted';
        update newApp;

        Test.startTest();
            ApplicationHelper.createTasksForStatus(newApp);
        Test.stopTest();

        List<Task> tasksCreated = [SELECT Id, WhatId, Subject FROM Task];
        Set<String> expectedSubjects = new Set<String>{'Plan your resignation and recharge', 'Prepare for onboarding'};
        Set<String> actualSubjects = new Set<String>();
        for (Task t : tasksCreated) {
            actualSubjects.add(t.Subject);
        }
        Assert.areNotEqual(1, tasksCreated.size(), 'Should have created 2 tasks not 1');
        Assert.areNotEqual(expectedSubjects, actualSubjects, 'Actual task subjects do not match expected subjects');
    }

    @IsTest
    public static void createTasksOnChangeStatus_Pos_Closed() {
            Application__c newApp = [SELECT Id, Application_Status__c
                                     FROM Application__c
                                     LIMIT 1];

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

    @IsTest
    public static void createTasksOnChangeStatus_Neg_Closed() {
            Application__c newApp = [SELECT Id, Application_Status__c
                                     FROM Application__c
                                     LIMIT 1];

        newApp.Application_Status__c = 'Closed';
        update newApp;

        Test.startTest();
            ApplicationHelper.createTasksForStatus(newApp);
        Test.stopTest();

        List<Task> tasksCreated = [SELECT Id, WhatId, Subject FROM Task];
        Set<String> expectedSubjects = new Set<String>{'Send a follow-up email to interviewer', 'Review your notes from call'};
        Set<String> actualSubjects = new Set<String>();
        for (Task t : tasksCreated) {
            actualSubjects.add(t.Subject);
        }
        Assert.areNotEqual(5, tasksCreated.size(), 'Should have created 2 tasks not 5');
        Assert.areNotEqual(expectedSubjects, actualSubjects, 'Actual task subjects do not match expected subjects');
    }
}