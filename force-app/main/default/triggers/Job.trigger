trigger Job on Job__c (after insert) {
    ApplicationHelper.setPrimaryContacts(Trigger.new);
}