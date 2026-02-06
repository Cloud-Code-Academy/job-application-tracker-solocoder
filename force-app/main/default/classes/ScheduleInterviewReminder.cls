/**
 * Send an email reminder the day before an interview is scheduled
 * Include relevant interview information in the email reminder
 */
public with sharing class ScheduleInterviewReminder Implements Schedulable {
    public void execute (SchedulableContext sc) {
        // Event to OwnerId
        
        Date tomorrow = Date.today().addDays(1);
        List<Event> interviewEvent = [SELECT Id, WhatId, StartDateTime, Subject
                                      FROM Event
                                      WHERE DAY_ONLY(StartDateTime) = :tomorrow
                                      AND Subject = 'Interview Scheduled'];
        if (!interviewEvent.isEmpty()) {
            for (Event evt : interviewEvent) {
                //
            }
        }
        // Get list of users and their email add
    }   // send email
}