trigger ApplicationTrigger on Application__c (before insert, after update, before update, after insert) {
    if (trigger.isBefore && trigger.isInsert) {
        Application.populateFederalTax(Trigger.new);
        }
    if (trigger.isBefore && trigger.isUpdate) {
        Application.populateUpdatedFederalTax(Trigger.new, Trigger.oldMap);
        }
    if (trigger.isAfter && trigger.isUpdate) {
        Application.createTasksOnChangeStatus(Trigger.new, Trigger.oldMap);
        }
    if (trigger.isAfter&& trigger.isInsert) {
        Application.createTasksOnNewRecordStatus(Trigger.new);
    }
}