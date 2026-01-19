trigger Job on Job__c (after insert) {
    JobApplicationHelper.setPrimaryContacts(Trigger.new);
}