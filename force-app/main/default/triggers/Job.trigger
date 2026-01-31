trigger Job on Job__c (after insert, before insert, after update) {
    if(Trigger.isAfter && Trigger.isInsert) {
        JobHelper.setPrimaryContacts(Trigger.new);
        JobHelper.populateStartingSalary(Trigger.new);
    }
}