/**
 * Utiity helper class
 */
public with sharing class UtilityHelper {
    /**
     * Create code validation to stop double-booking (scheduling two meetings simultaneously) or scheduling meetings on the weekend.
     * @param newEvents passes in a list of Events
     */

    public static void validateCalendarEvent(List<Event> newEvents) {
        // put ownerId's into set to query only these Ids with existing events in the newEvents
        Set<Id> ownerId = new Set<Id>();

        // loop over incoming list add ownerId to set
        for (Event newevnt : newEvents) {
            ownerId.add(newevnt.ownerId);
        }
        // get a list of already scheduled events for each ownerId that is coming into list
        List<Event> scheduledEvents = [SELECT Id, StartDateTime, EndDateTime, Description, OwnerId
                                       FROM Event
                                       WHERE StartDateTime >= TODAY
                                       AND OwnerId IN :ownerId
                                       WITH SECURITY_ENFORCED];

        // map the existing event to OwnerId
        Map<Event, Id> eventToOwnerId = new Map<Event, Id>();
        for (Event extevnt : scheduledEvents) {
            eventToOwnerId.put(extevnt, extevnt.OwnerId);
        }
    }
}