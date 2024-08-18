import 'dart:developer';
import 'package:googleapis/calendar/v3.dart';
import 'package:coordimate/app_state.dart';

class CalendarClient {
  Future<Map<String, String>> insert({
    required String title,
    required DateTime startTime,
    int duration = 60,
    String? description,
    String? location,
    List<EventAttendee>? attendeeEmailList,
    bool shouldNotifyAttendees = true,
    bool hasConferenceSupport = true,
  }) async {
    Map<String, String> eventData = {};

    // If the account has multiple calendars, then select the "primary" one
    String calendarId = "primary";
    Event event = Event();

    event.summary = title;
    if (description != null) event.description = description;
    if (attendeeEmailList != null) event.attendees = attendeeEmailList;
    if (location != null) event.location = location;

    EventDateTime start = EventDateTime();
    start.dateTime = startTime.toUtc();
    start.timeZone = "GMT";
    event.start = start;

    EventDateTime end = EventDateTime();
    end.dateTime = start.dateTime!.add(Duration(minutes: duration)).toUtc();
    end.timeZone = "GMT";
    event.end = end;

    if (hasConferenceSupport) {
      ConferenceData conferenceData = ConferenceData();
      CreateConferenceRequest conferenceRequest = CreateConferenceRequest();
      conferenceRequest.requestId =
      "${start.dateTime!.millisecondsSinceEpoch}-${end.dateTime!.millisecondsSinceEpoch}";
      conferenceData.createRequest = conferenceRequest;

      event.conferenceData = conferenceData;
    }

    try {
      await AppState.authController.calApi!.events
          .insert(event, calendarId,
          conferenceDataVersion: hasConferenceSupport ? 1 : 0,
          sendUpdates: shouldNotifyAttendees ? "all" : "none")
          .then((value) {
        log("Event Status: ${value.status}");
        if (value.status == "confirmed") {
          String joiningLink;
          String eventId;

          eventId = value.id!;

          if (hasConferenceSupport) {
            joiningLink =
            "https://meet.google.com/${value.conferenceData!.conferenceId}";
            eventData = {'id': eventId, 'link': joiningLink};
          } else {
            eventData = {'id': eventId};
          }

          log('Event added to Google Calendar');
        } else {
          log("Unable to add event to Google Calendar");
        }
      });
    } catch (e) {
      log('Error creating event $e');
    }
    return eventData;
  }

  Future<Map<String, String>> modify({
    required String id,
    required String title,
    required DateTime startTime,
    int duration = 60,
    String? description,
    String? location,
    List<EventAttendee>? attendeeEmailList,
    bool shouldNotifyAttendees = true,
    bool hasConferenceSupport = true,
  }) async {
    Map<String, String> eventData = {};

    String calendarId = "primary";
    Event event = Event();

    event.summary = title;
    if (description != null) event.description = description;
    if (attendeeEmailList != null) event.attendees = attendeeEmailList;
    if (location != null) event.location = location;

    EventDateTime start = EventDateTime();
    start.dateTime = startTime.toUtc();
    start.timeZone = "GMT";
    event.start = start;

    EventDateTime end = EventDateTime();
    end.dateTime = start.dateTime!.add(Duration(minutes: duration)).toUtc();
    end.timeZone = "GMT";
    event.end = end;

    try {
      await AppState.authController.calApi!.events
          .patch(event, calendarId, id,
          conferenceDataVersion: hasConferenceSupport ? 1 : 0,
          sendUpdates: shouldNotifyAttendees ? "all" : "none")
          .then((value) {
        log("Event Status: ${value.status}");
        if (value.status == "confirmed") {
          String joiningLink;
          String eventId;

          eventId = value.id!;

          if (hasConferenceSupport) {
            joiningLink =
            "https://meet.google.com/${value.conferenceData!.conferenceId}";
            eventData = {'id': eventId, 'link': joiningLink};
          } else {
            eventData = {'id': eventId};
          }

          log('Event updated in Google Calendar');
        } else {
          log("Unable to update event in Google Calendar");
        }
      });
    } catch (e) {
      log('Error updating event $e');
    }

    return eventData;
  }

  Future<void> delete(String eventId, bool shouldNotify) async {
    String calendarId = "primary";

    try {
      await AppState.authController.calApi!.events.delete(
          calendarId, eventId, sendUpdates: shouldNotify ? "all" : "none")
          .then((value) {
        log('Event deleted from Google Calendar');
      });
    } catch (e) {
      log('Error deleting event: $e');
    }
  }
}