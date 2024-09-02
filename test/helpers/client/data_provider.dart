//file to change data mocked for tests when widget-testing
import 'package:coordimate/models/groups.dart';
import 'package:coordimate/models/meeting.dart';

class DataProvider {
  static String groupID1 = "group1";
  static String groupID2 = "group2";
  static String groupName1 = "testGroup1";
  static String groupName2 = "testGroup2";
  static String groupDescr1 = "testDescription1";
  static String groupDescr2 = "testDescription2";
  static String longGroupDescr =
      "long group description long group description long group description long group description long group description long group description";
  //      "long group description long group description long group description long group description long group description long group description ";
  static String longGroupName = "12345687890123456789";
  //  "12345687890123456789"

  static String email1 = "test1@email.com";
  static String userID1 = "userID1";
  static String userID2 = "userID2";
  static String userID3 = "userID3";
  static String userID4 = "userID4";
  static String username1 = "testUser1";
  static String username2 = "testUser2";
  static String username3 = "testUser3";
  static String usernameAdmin = "testUserAdmin";
  static String meetingID1 = "meetingID1";
  static String meetingID2 = "meetingID2";
  static String meetingID3 = "meetingID3";
  static String meetingTitle1 = "testMeetingTitle1";
  static String meetingTitle2 = "testMeetingTitle2";
  static String meetingTitle3 = "testMeetingTitle3";
  static String meetingDescr1 = "testMeetingDescription1";
  static String meetingSummaryLong =
      "The world is changing and Tropico is moving with the times - geographical powers rise and fall and the world market is dominated by new players with new demands and offers - and you, as El Presidente, face a whole new set of challenges.";
  static String meetingSummaryShort =
      "The world is changing and Tropico is moving with the times";
  static String dateTimePast = "2022-01-01T12:00:00.000Z";
  static String dateTimeFuture = "2025-01-01T12:00:00.000Z";
  static DateTime dateTimePastObj = DateTime.parse(dateTimePast);
  static DateTime dateTimeFutureObj = DateTime.parse(dateTimeFuture);
  static String meetingLink = "https://meet.google.com/abc-123";

  static String getGroupName1() {
    return groupName1;
  }

  static String getGroupName2() {
    return groupName2;
  }

  static String getGroupDescr1() {
    return groupDescr1;
  }

  static String getGroupDescr2() {
    return groupDescr2;
  }

  static String getLongGroupDescr() {
    return longGroupDescr;
  }

  static String getLongGroupName() {
    return longGroupName;
  }

  //new group testing
  static String inviteLink = "https//:groupinvite.com";
  static String groupMeetingLink = "https//:groupmeeting.com";

  static String question = "this is a question?";
  static List<String> options = ["option1", "option2"];
  static Map<int, List<String>> votes = {
    0: [userID1, userID2],
    1: [userID3],
    2: [userID4],
  };
  static String userAdmin = "userAdmin";
  static String meetingTitle = "meetingTitle";
  static int meetingLength = 40;
  static String newgroupname = "new group name";
  static String newgroupdescr = "new group descr";
}
