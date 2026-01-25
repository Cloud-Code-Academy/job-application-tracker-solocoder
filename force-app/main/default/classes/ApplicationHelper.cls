/**
 * Application Helper
 */
public with sharing class ApplicationHelper {
    /**
     * This method caculates the federal taxes of the annual salary
     * @param annualSalary annualSalary the annual salary amount used for calculating taxes.
     * @return taxAmount calculated federal tax amount for the annual salary.
     */
    public static Decimal calculateFederalTax(Decimal annualSalary) {
        // calculate federal tax amount
        // get applicable tax brackets for salary amount
        List<Tax_Rate__c> applicableTaxRates = [SELECT  Tax_Rate_Type__c, Bracket_Min__c, Bracket_Max__c, Tax_Rate__c
                                                FROM Tax_Rate__c
                                                WHERE Tax_Rate_Type__c = 'Federal' AND Bracket_Min__c <= :annualSalary
                                                WITH SECURITY_ENFORCED
                                                ORDER BY Bracket_Min__c];
        Decimal remainingSalary = annualSalary;
        Decimal taxAmount = 0;
        for (Tax_Rate__c bracket : applicableTaxRates) {
            if (remainingSalary <= 0) {
                break;
            }
        // figure out the tax amount for each bracket
        Decimal lowerBracket = bracket.Bracket_Min__c;
        Decimal upperBracket = bracket.Bracket_Max__c != null? bracket.Bracket_Max__c : Decimal.valueOf(999999999);
        Decimal taxableBracketRange = upperBracket - lowerBracket;
        Decimal taxableAmount = Math.min(RemainingSalary, taxableBracketRange);
        Decimal taxOnBracket = taxableAmount * (bracket.Tax_Rate__c / 100);
        taxAmount += taxOnBracket;
        remainingSalary -= taxableAmount;
        }
        return taxAmount.setScale(2);
    }

    /**
    * This method caculates the medicare withholding on the annual salary
    * @param annualSalary annualSalary the annual salary amount used for calculating taxes.
    * @return Decimal calculated Medicare tax amount for the annual salary.
    */
    public static Decimal calculateMedicareTax(Decimal annualSalary) {
        // calculate Medicare tax
        List<Tax_Rate__c> medicareRate = [SELECT Tax_Rate_Type__c, Medicare_Threshold_Amount__c, Tax_Rate__c, Additional_Medicare_Tax_Rate__c
                                          FROM Tax_Rate__c
                                          WHERE Tax_Rate_Type__c = 'Medicare'
                                          WITH SECURITY_ENFORCED
                                          LIMIT 1];
        Decimal medicareTaxAmount = 0;
        Decimal taxAmountAboveThreshold = 0;
        if (annualSalary < medicareRate[0].Medicare_Threshold_Amount__c) {
            medicareTaxAmount = annualSalary * (medicareRate[0].Tax_Rate__c / 100);
        } else {
            taxAmountAboveThreshold = (annualSalary - medicareRate[0].Medicare_Threshold_Amount__c) * (medicareRate[0].Additional_Medicare_Tax_Rate__c / 100);
            medicareTaxAmount = (annualSalary * (medicareRate[0].Tax_Rate__c / 100)) + taxAmountAboveThreshold;
                }
        return medicareTaxAmount.setScale(2);
    }

    /**
    * This method caculates the social security on the annual salary
    * @param annualSalary annualSalary the annual salary amount used for calculating taxes.
    * @return Decimal calculated Social Security tax amount for the annual salary.
    */
    public static Decimal calculateSocialSecurityTax(Decimal annualSalary) {
        // calculate Social Security tax
        List<Tax_Rate__c> socialSecurityRate = [SELECT Tax_Rate_Type__c, Tax_Rate__c, Social_Security_Wage_Limit__c
                                                FROM Tax_Rate__c
                                                WHERE Tax_Rate_Type__c = 'Social Security'
                                                WITH SECURITY_ENFORCED
                                                LIMIT 1];
        Decimal taxableAmount = Math.min(annualSalary, socialSecurityRate[0].Social_Security_Wage_Limit__c);
        Decimal socialSecurityTaxAmount = taxableAmount * (socialSecurityRate[0].Tax_Rate__c / 100);
        // System.debug('TaxableAmount::: ' + taxableAmount + ' Social Security Tax Amount::: ' + socialSecurityTaxAmount);
        return socialSecurityTaxAmount.setScale(2);
    }

    /**
    * This method creates task(s) based on the application status field
    * @param app record
    * @return List returns a list of tasks to be created
     */
    public static List<Task> createTasksForStatus(Application__c app) {
        // create tasks associated with application status
        List<Task> tasksToCreate = new List<Task>();
        switch on app.Application_Status__c {
            when 'Saved' {
                tasksToCreate.add(new Task(
                    WhatId = app.Id,
                    Subject = 'Validate job alignment',
                    Status = 'Not Started',
                    Priority = 'Normal',
                    ActivityDate = Date.today().addDays(1),
                    Description = '- Check if the job description aligns with your interests and values'
                ));
                tasksToCreate.add(new Task(
                    WhatId = app.Id,
                    Subject = 'Review skills for fit',
                    Status = 'Not Started',
                    Priority = 'Normal',
                    ActivityDate = Date.today().addDays(1),
                    Description = '- Review the highlighted skills to see if the role is a good fit'
                ));
                tasksToCreate.add(new Task(
                    WhatId = app.Id,
                    Subject = 'Mark excitement level',
                    Status = 'Not Started',
                    Priority = 'Normal',
                    ActivityDate = Date.today().addDays(1),
                    Description = '- Research the company or role and mark your excitement level'
                ));
            }
            when 'Applying' {
                tasksToCreate.add(new Task(
                    WhatId = app.Id,
                    Subject = 'Research - find someone who works at company',
                    Status = 'Not Started',
                    Priority = 'Normal',
                    ActivityDate = Date.today().addDays(1),
                    Description = '- Find and research someone who works at the company and add them as a contact'
                ));
                tasksToCreate.add(new Task(
                    WhatId = app.Id,
                    Subject = 'Set informal interview',
                    Status = 'Not Started',
                    Priority = 'Normal',
                    ActivityDate = Date.today().addDays(1),
                    Description = '- Set up an informational interview to learn more about the role/company'
                ));
                tasksToCreate.add(new Task(
                    WhatId = app.Id,
                    Subject = 'Identify potential referrals',
                    Status = 'Not Started',
                    Priority = 'Normal',
                    ActivityDate = Date.today().addDays(1),
                    Description = '- Identify potential referrals to help get your application on the top of the pile'
                ));
                tasksToCreate.add(new Task(
                    WhatId = app.Id,
                    Subject = 'Customize achievements',
                    Status = 'Not Started',
                    Priority = 'Normal',
                    ActivityDate = Date.today().addDays(1),
                    Description = '- Customize your work achievements using the job description keywords'
                ));
                tasksToCreate.add(new Task(
                    WhatId = app.Id,
                    Subject = 'Submit application to Company webiste',
                    Status = 'Not Started',
                    Priority = 'Normal',
                    ActivityDate = Date.today().addDays(1),
                    Description = '- Submit your application on the company website if possible'
                ));
            }
            when 'Applied' {
                tasksToCreate.add(new Task(
                    WhatId = app.Id,
                    Subject = 'Reach out to hiring manager',
                    Status = 'Not Started',
                    Priority = 'Normal',
                    ActivityDate = Date.today().addDays(1),
                    Description = '- Reach out to the hiring manager or recruiter'
                ));
                tasksToCreate.add(new Task(
                    WhatId = app.Id,
                    Subject = 'Follow up on your application',
                    Status = 'Not Started',
                    Priority = 'Normal',
                    ActivityDate = Date.today().addDays(2),
                    Description = '- Follow up on your application via email weekly'
                ));
                tasksToCreate.add(new Task(
                    WhatId = app.Id,
                    Subject = 'Identify and save similar job opps',
                    Status = 'Not Started',
                    Priority = 'Normal',
                    ActivityDate = Date.today().addDays(1),
                    Description = '- Continue identifying and saving similar job opportunities'
                ));
                tasksToCreate.add(new Task(
                    WhatId = app.Id,
                    Subject = 'Set up weekly networking calls',
                    Status = 'Not Started',
                    Priority = 'Normal',
                    ActivityDate = Date.today().addDays(1),
                    Description = '- Set up weekly networking calls to explore similar companies/roles'
                ));
            }
            when 'Interviewing' {
                tasksToCreate.add(new Task(
                    WhatId = app.Id,
                    Subject = 'Prepare elevator pitch',
                    Status = 'Not Started',
                    Priority = 'High',
                    ActivityDate = Date.today().addDays(1),
                    Description = '- Prepare your blurb or “tell me about yourself” response'
                ));
                tasksToCreate.add(new Task(
                    WhatId = app.Id,
                    Subject = 'Practice interview questions',
                    Status = 'Not Started',
                    Priority = 'High',
                    ActivityDate = Date.today().addDays(1),
                    Description = '- Practice answering behavioral interview questions'
                ));
                tasksToCreate.add(new Task(
                    WhatId = app.Id,
                    Subject = 'Research company and interviewers',
                    Status = 'Not Started',
                    Priority = 'Normal',
                    ActivityDate = Date.today().addDays(2),
                    Description = '- Research the company and your interviewers'
                ));
                tasksToCreate.add(new Task(
                    WhatId = app.Id,
                    Subject = 'Prepare for virtual interiew',
                    Status = 'Not Started',
                    Priority = 'Normal',
                    ActivityDate = Date.today().addDays(2),
                    Description = '- Set up your virtual interview space and test your tech'
                ));
                tasksToCreate.add(new Task(
                    WhatId = app.Id,
                    Subject = 'Send Thank you emails',
                    Status = 'Not Started',
                    Priority = 'Normal',
                    ActivityDate = Date.today().addDays(2),
                    Description = '- Send thank you emails within 24 hours'
                ));
            }
            when 'Negotiating' {
                tasksToCreate.add(new Task(
                    WhatId = app.Id,
                    Subject = 'Salary research',
                    Status = 'Not Started',
                    Priority = 'High',
                    ActivityDate = Date.today().addDays(1),
                    Description = '- Research your market value and know your numbers'
                ));
                tasksToCreate.add(new Task(
                    WhatId = app.Id,
                    Subject = 'Prepare your negotiation scripts',
                    Status = 'Not Started',
                    Priority = 'High',
                    ActivityDate = Date.today().addDays(1),
                    Description = '- Prepare your negotiation scripts'
                ));
                tasksToCreate.add(new Task(
                    WhatId = app.Id,
                    Subject = 'Evaluate your offer',
                    Status = 'Not Started',
                    Priority = 'High',
                    ActivityDate = Date.today().addDays(1),
                    Description = '- Evaluate your offer and decline or accept'
                ));
            }
            when 'Accepted' {
                tasksToCreate.add(new Task(
                    WhatId = app.Id,
                    Subject = 'Plan your resignation and recharge',
                    Status = 'Not Started',
                    Priority = 'Normal',
                    ActivityDate = Date.today().addDays(2),
                    Description = '- Plan your resignation if applicable \n - Take some time to relax and recharge'
                ));
                tasksToCreate.add(new Task(
                    WhatId = app.Id,
                    Subject = 'Prepare for your first day of onboarding',
                    Status = 'Not Started',
                    Priority = 'High',
                    ActivityDate = Date.today().addDays(2),
                    Description = '- Prepare for your first day of onboarding'
                ));
            }
            when 'Closed' {
                tasksToCreate.add(new Task(
                    WhatId = app.Id,
                    Subject = 'Send a follow-up email to interviewer',
                    Status = 'Not Started',
                    Priority = 'High',
                    ActivityDate = Date.today().addDays(1),
                    Description = '- Send a follow-up email thanking the interviewer and asking for feedback'
                ));
                tasksToCreate.add(new Task(
                    WhatId = app.Id,
                    Subject = 'Review your notes',
                    Status = 'Not Started',
                    Priority = 'Normal',
                    ActivityDate = Date.today().addDays(3),
                    Description = '- Review your notes and reflect on areas of improvement'
                ));
            }
        }
        return tasksToCreate;
    }
}