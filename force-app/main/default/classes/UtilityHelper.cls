/**
 * Utiity helper class
 */
public with sharing class UtilityHelper {
    /**
     * Create code validation to stop double-booking (scheduling two meetings simultaneously) or scheduling meetings on the weekend.
     * @param newEvents passes in a list of Events
     */
    public static void validateCalendarEvent(List<Event> newEvents) {
        // get a list of already scheduled events
        List<Event> existingEvents = [SELECT Id, StartDateTime
                                      FROM Event
                                      WHERE StartDateTime >= TODAY
                                      WITH SECURITY_ENFORCED];
        // get a list of all the start times for these events
        List<Datetime> existingDateTimes = new List<Datetime>();
        if (!existingEvents.isEmpty()) {
            for (Event evnt : existingEvents) {
            existingDateTimes.add(evnt.StartDateTime);
            }
        }
        // if current time is already in the list
        for (Event newEvent : newEvents) {
            if (existingDateTimes.contains(newEvent.StartDateTime)) {
                newEvent.addError('There is already an appointment on the calendar for this time');
            }
        }
    }
}