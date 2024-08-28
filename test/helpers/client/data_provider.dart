//file to change data mocked for tests when widget-testing
class DataProvider {
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
  static String username1 = "testUser1";
  static String username2 = "testUser2";
  static String usernameAdmin = "testUserAdmin";
  static String meetingTitle1 = "testMeetingTitle1";
  static String meetingDescr1 = "testMeetingDescription1";
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
}
