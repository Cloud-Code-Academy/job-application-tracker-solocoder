trigger ApplicationTrigger on Application__c (before insert, after update) {
    if (trigger.isBefore && trigger.isInsert) {
            Application.populateFederalTax(Trigger.new);
        }
    if (trigger.isAfter && trigger.isUpdate) {
            Application.createTasksOnChangeStatus(Trigger.new, Trigger.oldMap);
        }
}