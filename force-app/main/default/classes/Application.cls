/**
 * Application class
 */
public with sharing class Application {
    /**
     * This method assigns the applicable tax to each tax field by calling out the helper method that calculates each tax
     * @param applications List of new or updated application records
     */
    public static void populateFederalTax(List<Application__c> applications) {
        if (!applications.isEmpty()) {
           for (Application__c app : applications) {
            app.Federal_Tax_Amount__c = ApplicationHelper.calculateFederalTax(app.Annual_Salary__c);
            app.Medicare_Withholding__c = ApplicationHelper.calculateMedicareTax(app.Annual_Salary__c);
            app.Social_Security__c = ApplicationHelper.calculateSocialSecurityTax(app.Annual_Salary__c);
            }
        }
    }
    /**
     * This method inserts tasks based on the task status of Application records
     * @param newApps list of new applications
     * @param oldAppMap list of old values in list of applications
     */
    public static void createTasksOnChangeStatus(List<Application__c> newApps, Map<Id, Application__c> oldAppMap) {
        if(!newApps.isEmpty()){
            List<Task> tasksToCreate = new List<Task>();

            for (Application__c app : newApps) {
                Application__c oldApp = oldAppMap.get(app.Id);
                if (app.Application_Status__c != oldApp.Application_Status__c) {
                    List<Task> newTasks = ApplicationHelper.createTasksForStatus(app);
                    tasksToCreate.addAll(newTasks);
                }
            }
            if (!tasksToCreate.isEmpty()) {
                Database.insert(tasksToCreate, AccessLevel.USER_MODE);
            }
        }
    }
}