/**
 * Moves the record status to closed and dpdate the notes field that the job application was closed by an automated process. Stale Criteria:
 * Status is not Closed or Accepted
 * Follow Date 30 days old or more
 */
public with sharing class ScheduleApplicationCleanUp implements Schedulable {
    public void execute (SchedulableContext sc) {
        List<Application__c> applications = [SELECT Id, Application_Status__c, Follow__c
                                             FROM Application__c
                                             WHERE Application_Status__c NOT IN ('Closed', 'Accepted') AND Follow__c <= :Date.today().addDays(-30)];

        if (!applications.isEmpty()) {
            for (Application__c app : applications) {
                app.Application_Status__c = 'Closed';
                app.Notes__c = 'This job application was closed by an automated process';
            }
        }
        update applications;
    }
}
    /*
    // get set of Application Id to run list of open tasks to close
        Set<Id> applicationId = new Set<Id>();
        List<Task> tasksToClose = [SELECT Id, Status, WhatId 
                                   FROM Task 
                                   WHERE WhatId IN :applicationId
                                   AND Status != 'Completed'];
    */