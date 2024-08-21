import 'package:coordimate/widget_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:coordimate/app_state.dart';
import 'package:coordimate/models/user.dart';
import 'package:coordimate/models/groups.dart';
import 'package:coordimate/models/meeting.dart';
import 'package:coordimate/pages/schedule_page.dart';
import 'package:coordimate/pages/meetings_archive.dart';
import 'package:coordimate/components/colors.dart';
import 'package:coordimate/components/create_meeting_dialog.dart';
import 'package:coordimate/components/appbar.dart';
import 'package:coordimate/components/divider.dart';
import 'package:coordimate/components/meeting_tiles.dart';
import 'package:coordimate/components/snack_bar.dart';
import 'package:coordimate/components/text_field_with_edit.dart';
import 'package:coordimate/components/avatar.dart';
import 'package:coordimate/components/pop_up_dialog.dart';
import 'package:coordimate/components/delete_button.dart';

class GroupDetailsPage extends StatefulWidget {
  final Group group;

  const GroupDetailsPage({super.key, required this.group});

  @override
  GroupDetailsPageState createState() => GroupDetailsPageState();
}

class GroupDetailsPageState extends State<GroupDetailsPage> {
  List<UserCard> users = [];
  List<MeetingTileModel> meetings = [];
  final String pathPerson = 'lib/images/person.png';

  final groupDescriptionController = TextEditingController();
  final groupNameController = TextEditingController();
  final groupEmptyDescriptionController = TextEditingController();

  final FocusNode focusNode = FocusNode();
  static const universalFontSize = 16.0;
  static const horPadding = 0.0;
  var userEmail = '';
  var showChangePasswordButton = true;

  final textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMeetings();
    _fetchUsers();
    groupDescriptionController.text = widget.group.description;
    groupNameController.text = widget.group.name;
    groupEmptyDescriptionController.text = "No group description";
  }

  Future<void> _fetchUsers() async {
    final usersFetched =
        await AppState.groupController.fetchGroupUsers(widget.group.id);
    setState(() {
      users = usersFetched;
    });
  }

  Future<void> _fetchMeetings() async {
    final meetingsFetched =
        await AppState.groupController.fetchGroupMeetings(widget.group.id);
    setState(() {
      meetings = meetingsFetched;
    });
  }

  void _onCreateMeeting() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CreateMeetingDialog(
            groupId: widget.group.id,
            pickedDate: DateTime.now().add(const Duration(minutes: 10)));
      },
    ).then((_) async {
      await _fetchMeetings();
    });
  }

  void _showDeleteGroupDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomPopUpDialog(
          question: "Do you want to delete group \n\"${widget.group.name}\"?",
          onYes: () async {
            // TODO: Implement delete group
            // await AppState.groupController.deleteGroup(widget.group.id);
          },
          onNo: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<MeetingTileModel> declinedMeetings = meetings
        .where((meeting) => meeting.status == MeetingStatus.declined)
        .toList();
    List<MeetingTileModel> acceptedMeetings = meetings
        .where((meeting) => meeting.status == MeetingStatus.accepted)
        .toList();
    List<MeetingTileModel> acceptedPassedMeetings = acceptedMeetings
        .where((meeting) => meeting.dateTime.isBefore(DateTime.now()))
        .toList();
    List<MeetingTileModel> acceptedFutureMeetings = acceptedMeetings
        .where((meeting) => meeting.dateTime.isAfter(DateTime.now()))
        .toList();
    List<MeetingTileModel> archivedMeetings =
        acceptedPassedMeetings + declinedMeetings;
    archivedMeetings.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "",
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(
                context, true); // Pass a result of `true` when popping
          },
        ),
        needButton: true,
        buttonIcon: Icons.archive,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MeetingsArchivePage(
                  meetings: archivedMeetings,
                  fetchMeetings: _fetchMeetings,
              ),
            ),
          );
        },
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.group_add),
                    iconSize: 43.0,
                    onPressed: () async {
                      final link = await AppState.groupController
                          .shareInviteLink(widget.group.id);
                      Share.share(link);
                    },
                  ),
                  Avatar(
                      key: avatarKey,
                      size: 100,
                      groupId: widget.group.id,
                      clickable: true),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    iconSize: 43.0,
                    onPressed: () {
                      _onCreateMeeting();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Center(
                child: EditableTextField(
                  controller: groupNameController,
                  focusNode: focusNode,
                  onSubmit: (String s) {
                    AppState.groupController
                        .updateGroupName(widget.group.id, s);
                  },
                  fontSize: universalFontSize,
                  padding: horPadding,
                  maxLength: 20,
                  iconSize: 20.0,
                  horizontalPadding: 40.0,
                  textAlign: TextAlign.center,
                  minChars: 3,
                ),
              ),
              Center(
                child: Text(
                  '${users.length} Member ${users.length > 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: textController,
                    decoration: InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: alphaDarkBlue,
                          ),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: darkBlue,
                          ),
                        ),
                        hintText: 'Insert link or address here',
                        hintStyle: TextStyle(color: alphaDarkBlue),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              onPressed: () {
                                Clipboard.setData(
                                    ClipboardData(text: textController.text));
                                CustomSnackBar.show(
                                    context, "Copied to clipboard",
                                    duration: const Duration(seconds: 1));
                              },
                              icon: const Icon(Icons.copy, color: darkBlue),
                              color: darkBlue,
                            ),
                            IconButton(
                              onPressed: () {
                                Share.share(textController.text);
                              },
                              icon: const Icon(Icons.share, color: darkBlue),
                              color: darkBlue,
                            ),
                          ],
                        )),
                  )),
              const SizedBox(height: 16.0),
              SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (widget.group.description.isNotEmpty)
                      Container(
                        constraints:
                            const BoxConstraints(minWidth: double.infinity),
                        child: EditableTextField(
                          controller: groupDescriptionController,
                          focusNode: focusNode,
                          onSubmit: (String s) {
                            AppState.groupController
                                .updateGroupDescription(widget.group.id, s);
                          },
                          fontSize: universalFontSize,
                          padding: horPadding,
                          maxLength: 100,
                          iconSize: 20.0,
                          horizontalPadding: 40.0,
                          textAlign: TextAlign.justify,
                          // minChars: 5,
                          //errorMessage: 'Please enter at least 5 characters',
                          //maxLines: null,
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: EditableTextField(
                          placeHolderText: "No Group Description",
                          controller: groupDescriptionController,
                          focusNode: focusNode,
                          onSubmit: (String s) {
                            AppState.groupController
                                .updateGroupDescription(widget.group.id, s);
                          },
                          fontSize: universalFontSize,
                          padding: horPadding,
                          maxLength: 100,
                          iconSize: 20.0,
                          horizontalPadding: 40.0,
                          textAlign: TextAlign.center,
                          // minChars: 5,
                          textColor: darkBlue,
                          //errorMessage: 'Please enter at least 5 characters',
                          //maxLines: null,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              if (acceptedFutureMeetings.isNotEmpty)
                _buildMeetingList(
                    acceptedFutureMeetings, "Upcoming Meetings", true, 55)
              else
                _buildMeetingList(
                    acceptedFutureMeetings, "No Upcoming Meetings", true, 40),
              const SizedBox(height: 16.0),
              if (users.isNotEmpty)
                _buildUserList(users, "Group Members")
              else
                _buildUserList(users, "No Group Members"),
              Container(
                color: white,
                padding: const EdgeInsets.only(bottom: 16.0),
                child: DeleteButton(
                  itemToDelete: 'Group',
                  showDeleteDialog: _showDeleteGroupDialog,
                  color: orange,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeetingList(
      List<MeetingTileModel> meetings, String title, bool button,
      [double stripeWidth = 0]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        button
            ? Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 1,
                      color: darkBlue,
                      width: stripeWidth,
                    ),
                    const SizedBox(width: 5),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkBlue,
                        foregroundColor: white,
                      ),
                      onPressed: () async {
                        Navigator.of(context)
                            .push(MaterialPageRoute(
                                builder: (context) => SchedulePage(
                                    isGroupSchedule: true,
                                    ownerId: widget.group.id,
                                    ownerName: widget.group.name)))
                            .then((_) async {
                          await _fetchMeetings();
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                        child: Text(
                          title,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      height: 1,
                      color: darkBlue,
                      width: stripeWidth,
                    ),
                  ],
                ),
              )
            : CustomDivider(text: title),
        const SizedBox(height: 16),
        ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: meetings.length,
          itemBuilder: (context, index) {
            if (meetings[index].status == MeetingStatus.declined) {
              return ArchivedMeetingTile(
                meeting: meetings[index],
                fetchMeetings: _fetchMeetings,
              );
            } else if (meetings[index].status == MeetingStatus.accepted) {
              return AcceptedMeetingTile(
                meeting: meetings[index],
                fetchMeetings: _fetchMeetings,
              );
            } else {
              return const Text("No one will see this");
            }
          },
        ),
      ],
    );
  }

  Widget _buildUserList(List<UserCard> users, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomDivider(text: title),
        const SizedBox(height: 8),
        ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: users.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => SchedulePage(
                        isGroupSchedule: false,
                        ownerId: users[index].id,
                        ownerName: "${users[index].username}'s schedule")));
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: darkBlue, width: 1),
                ),
                child: ListTile(
                  leading: Avatar(
                      key: Key('avatar${users[index].id}'), userId: users[index].id, size: 40),
                  title: Text(
                    users[index].username,
                    style: const TextStyle(
                      fontSize: 16,
                      color: darkBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
