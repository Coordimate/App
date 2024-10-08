import 'package:coordimate/components/group_poll_card.dart';
import 'package:coordimate/models/chat_message.dart';
import 'package:coordimate/pages/group_chat_page.dart';
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
  GroupPoll? poll;

  final groupDescriptionController = TextEditingController();
  final groupNameController = TextEditingController();
  final groupEmptyDescriptionController = TextEditingController();

  final FocusNode focusNode = FocusNode();
  static const universalFontSize = 20.0;
  static const horPadding = 0.0;
  var userEmail = '';
  var showChangePasswordButton = true;

  final textController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchMeetings();
    _fetchUsers();
    groupDescriptionController.text = widget.group.description;
    groupNameController.text = widget.group.name;
    groupEmptyDescriptionController.text = "No group description";
    textController.text = widget.group.groupMeetingLink;
    poll = widget.group.poll;
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
    setState(() {
      _isLoading = true;
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CreateMeetingDialog(
            groupId: widget.group.id,
            pickedDate: DateTime.now().add(const Duration(minutes: 10)));
      },
    ).then((_) async {
      await _fetchMeetings();
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _showDeleteGroupDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomPopUpDialog(
          question: "Do you want to delete group \n\"${widget.group.name}\"?",
          onYes: () async {
            await AppState.groupController.deleteGroup(widget.group.id);
            if (context.mounted) {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            }
          },
          onNo: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _showLeaveGroupDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomPopUpDialog(
          question: "Do you want to leave group \n\"${widget.group.name}\"?",
          onYes: () async {
            await AppState.groupController.leaveGroup(widget.group.id);
            if (context.mounted) {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            }
          },
          onNo: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _showRemoveUserDialog(username, userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomPopUpDialog(
          question: "Do you want to remove \n\"$username\"?",
          onYes: () async {
            await AppState.groupController.removeUser(widget.group.id, userId);
            if (context.mounted) {
              _fetchUsers();
              Navigator.of(context).pop();
            }
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
    List<MeetingTileModel> acceptedMeetings = meetings
        .where((meeting) =>
    meeting.status == MeetingStatus.accepted && !meeting.isFinished)
        .toList();
    List<MeetingTileModel> acceptedFutureMeetings = acceptedMeetings
        .where((meeting) =>
    meeting.dateTime.add(Duration(minutes: meeting.duration)).isAfter(DateTime.now()) && !meeting.isFinished)
        .toList();
    List<MeetingTileModel> archivedMeetings = meetings
        .where((meeting) =>
    meeting.status == MeetingStatus.declined ||
        meeting.isFinished ||
        meeting.isInPast())
        .toList();
    archivedMeetings.sort((a, b) =>
    b.dateTime.difference(DateTime.now()).inSeconds -
        a.dateTime.difference(DateTime.now()).inSeconds);

    final isAdmin = widget.group.adminId == AppState.authController.userId;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "",
        needButton: true,
        buttonIcon: Icons.archive_rounded,
        buttonColor: alphaDarkBlue,
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
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    key: inviteButtonKey,
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
                      key: createMeetingButtonKey,
                      icon: const Icon(Icons.add_circle_outline_rounded),
                      iconSize: 43.0,
                      onPressed: _isLoading ? null : _onCreateMeeting),
                ],
              ),
              const SizedBox(height: 16.0),
              Center(
                child: EditableTextField(
                  key: groupNameFieldKey,
                  controller: groupNameController,
                  focusNode: focusNode,
                  onSubmit: (String s) {
                    AppState.groupController
                        .updateGroupName(widget.group.id, s);
                  },
                  fontSize: universalFontSize + 4.0,
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
                  key: groupMemberCountKey,
                  '${users.length} Member${users.length > 1 ? 's' : ''}',
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
                    key: linkPlaceholderFieldKey,
                    onSubmitted: (String s) async {
                      await AppState.groupController
                          .updateGroupMeetingLink(widget.group.id, s);
                    },
                    onTapOutside: (_) async {
                      await AppState.groupController.updateGroupMeetingLink(
                          widget.group.id, textController.text);
                    },
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
                              key: copyButtonKey,
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
                              key: shareButtonKey,
                              onPressed: () {
                                if (textController.text.isNotEmpty) {
                                  Share.share(textController.text);
                                }
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
                          key: groupDescriptionFieldKey,
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
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: EditableTextField(
                          key: noGroupDescriptionFieldKey,
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
                          textColor: darkBlue,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GroupPollCard(
                  key: pollPanelKey,
                  groupId: widget.group.id,
                  initialPoll: poll,
                  fontSize: universalFontSize,
                  isAdmin: isAdmin),
              const SizedBox(height: 16.0),
              _buildMeetingList(
                  acceptedFutureMeetings, "Group Schedule", true, 80),
              const SizedBox(height: 14.0),
              if (users.isNotEmpty)
                _buildUserList(users, "Group Members")
              else
                _buildUserList(users, "No Group Members"),
              if (isAdmin)
                Container(
                    key: deleteGroupButtonKey,
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: DeleteButton(
                      str: 'Delete Group',
                      showDeleteDialog: _showDeleteGroupDialog,
                      color: orange,
                    ))
              else
                Container(
                    key: leaveGroupButtonKey,
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: DeleteButton(
                      str: 'Leave Group',
                      showDeleteDialog: _showLeaveGroupDialog,
                      color: orange,
                    )),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: groupChatButtonKey,
        backgroundColor: mediumBlue,
        foregroundColor: white,
        onPressed: () async {
          Map<String, Avatar> memberAvatars = {};
          Map<String, String> memberUsernames = {};

          var users =
              await AppState.groupController.fetchGroupUsers(widget.group.id);
          for (int i = 0; i < users.length; i++) {
            memberUsernames[users[i].id] = users[i].username;
            memberAvatars[users[i].id] = Avatar(size: 30, userId: users[i].id);
          }

          String lastSenderId = '';
          List<ChatMessageModel> messages = await AppState.groupController
              .fetchGroupChatMessages(widget.group.id);
          late List<ChatMessage> chatMessages = messages.map((msg) {
            var chatMsg = ChatMessage(
                avatar: memberAvatars[msg.userId] ?? const Avatar(size: 30),
                username: memberUsernames[msg.userId] ?? "deleted user",
                text: msg.text,
                isFromUser: AppState.authController.userId == msg.userId,
                isFirst: lastSenderId != msg.userId);
            lastSenderId = msg.userId;
            return chatMsg;
          }).toList();

          if (context.mounted) {
            Navigator.of(context)
                .push(MaterialPageRoute(
                    builder: (context) => GroupChatPage(
                          chatMessages: chatMessages,
                          memberAvatars: memberAvatars,
                          memberUsernames: memberUsernames,
                          title: '${widget.group.name} Chat',
                          userId: AppState.authController.userId!,
                          groupId: widget.group.id,
                        )))
                .then((_) async {
              await _fetchMeetings();
            });
          }
        },
        child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            child: Icon(Icons.chat_outlined)),
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
                    const Expanded(
                      child: Divider(
                        height: 1,
                        color: darkBlue,
                      ),
                    ),
                    GestureDetector(
                      key: groupScheduleButtonKey,
                      onTap: () async {
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
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 16),
                        decoration: BoxDecoration(
                          color: mediumBlue,
                          border: Border.all(color: mediumBlue, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(
                        height: 1,
                        color: darkBlue,
                      ),
                    ),
                  ],
                ),
              )
            : CustomDivider(text: title),
        if (meetings.isNotEmpty) const SizedBox(height: 16),
        ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: meetings.length,
          itemBuilder: (context, index) {
            if (meetings[index].status == MeetingStatus.accepted) {
              return AcceptedMeetingTile(
                key: groupAcceptedMeetingKey,
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
    final isAdmin = widget.group.adminId == AppState.authController.userId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomDivider(text: title),
        const SizedBox(height: 8),
        ListView.builder(
          key: groupMembersListKey,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: users.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              key: groupMemberKey,
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
                      key: Key('avatar${users[index].id}'),
                      userId: users[index].id,
                      size: 40),
                  trailing: users[index].id == widget.group.adminId
                      ? const Text("admin",
                          style: TextStyle(fontSize: 16, color: darkBlue))
                      : (isAdmin
                          ? IconButton(
                              onPressed: () {
                                _showRemoveUserDialog(
                                    users[index].username, users[index].id);
                              },
                              icon: const Icon(Icons.close, color: darkBlue))
                          : const SizedBox()),
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
