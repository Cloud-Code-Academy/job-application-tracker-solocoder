trigger EventTrigger on Event (before insert) {
    UtilityHelper.validateCalendarEvent(Trigger.new);
}