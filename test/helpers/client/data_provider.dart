//file to change data mocked for tests when widget-testing
//dataprovider
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
