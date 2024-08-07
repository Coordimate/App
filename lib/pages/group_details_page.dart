import 'package:another_flushbar/flushbar.dart';
import 'package:coordimate/components/colors.dart';
import 'package:coordimate/components/login_button.dart';
import 'package:coordimate/components/pop_up_dialog.dart';
import 'package:coordimate/models/user.dart';
import 'package:coordimate/pages/schedule_page.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:coordimate/components/appbar.dart';
import 'package:flutter/material.dart';
import 'package:coordimate/models/groups.dart';
import 'package:coordimate/components/divider.dart';
import 'package:coordimate/components/meeting_tiles.dart';
import 'package:coordimate/models/meeting.dart';
import 'package:intl/intl.dart';
import 'package:coordimate/pages/meetings_archive.dart';
import 'package:coordimate/components/snack_bar.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:coordimate/app_state.dart';
import 'package:coordimate/components/text_field_with_edit.dart';

class GroupDetailsPage extends StatefulWidget {
  final Group group;

  //ToDo: understand whatever this blue line means here
  const GroupDetailsPage({super.key, required this.group});

  @override
  GroupDetailsPageState createState() => GroupDetailsPageState();
}

class GroupDetailsPageState extends State<GroupDetailsPage> {
  List<UserCard> users = [];
  List<MeetingTileModel> meetings = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(minutes: 10));
  Duration _selectedDuration = const Duration(minutes: 60);
  final String pathPerson = 'lib/images/person.png';
  final _formKey = GlobalKey<FormState>();

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

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
                primary: lightBlue,
                onPrimary: darkBlue,
                onSurface: darkBlue,
                surfaceTint: Colors.white),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: darkBlue,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          _selectedDate.hour,
          _selectedDate.minute,
        );
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
                primary: lightBlue,
                onPrimary: darkBlue,
                onSurface: darkBlue,
                surfaceTint: Colors.white),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: darkBlue,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedTime != null) {
      setState(() {
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  Future<void> _setDuration() async {
    final Duration? pickedDuration = await showDurationPicker(
      context: context,
      initialTime: _selectedDuration,
      baseUnit: BaseUnit.minute,
      upperBound: const Duration(hours: 24),
      lowerBound: const Duration(minutes: 15),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    );
    if (pickedDuration != null) {
      setState(() {
        _selectedDuration = Duration(
            hours: pickedDuration.inHours,
            minutes: pickedDuration.inMinutes.remainder(60));
      });
    }
  }

  void clearControllers() {
    _titleController.clear();
    _descriptionController.clear();
    _selectedDate = DateTime.now().add(const Duration(minutes: 10));
    _selectedDuration = const Duration(minutes: 60);
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60).abs());
    if (duration.inHours == 0) {
      return "${twoDigitMinutes}m";
    } else if (duration.inMinutes.remainder(60) == 0) {
      return "${duration.inHours}h";
    }
    return "${duration.inHours}h ${twoDigitMinutes}m";
  }

  void _onCreateMeeting() {
    _selectedDate = DateTime.now().add(const Duration(minutes: 10));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              elevation: 0,
              title: const Center(child: Text('Create Meeting')),
              titleTextStyle: const TextStyle(
                color: darkBlue,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
              alignment: Alignment.center,
              backgroundColor: Colors.white,
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: _titleController,
                        style: const TextStyle(color: darkBlue),
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          labelStyle: TextStyle(color: darkBlue),
                          hintText: 'Enter the title of the meeting',
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: darkBlue),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: darkBlue, width: 2.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    LoginEmptyButton(
                      text: DateFormat('EEE, MMMM d, y')
                          .format(_selectedDate.toLocal())
                          .toString(),
                      onTap: () async {
                        await _selectDate();
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 16),
                    LoginEmptyButton(
                      text: DateFormat('HH:mm')
                          .format(_selectedDate.toLocal())
                          .toString(),
                      onTap: () async {
                        await _selectTime();
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        "Estimated duration",
                        style: TextStyle(
                          color: darkBlue,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    LoginEmptyButton(
                      text: _printDuration(_selectedDuration),
                      onTap: () async {
                        await _setDuration();
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      style: const TextStyle(color: darkBlue),
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Enter the description of the meeting',
                        labelStyle: TextStyle(color: darkBlue),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: darkBlue),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: darkBlue, width: 2.0),
                        ),
                      ),
                      maxLines: null,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                ConfirmationButtons(
                  onYes: () {
                    if (_formKey.currentState!.validate() == false) {
                      return;
                    }
                    if (_selectedDate.isBefore(
                        DateTime.now().add(const Duration(minutes: 5)))) {
                      Flushbar(
                        message: 'Meeting needs to be at least in 5 minutes',
                        backgroundColor: orange,
                        duration: const Duration(seconds: 2),
                        flushbarPosition: FlushbarPosition.TOP,
                      ).show(context);
                    } else {
                      AppState.groupController.createMeeting(
                          _titleController.text,
                          _selectedDate.toIso8601String(),
                          _descriptionController.text,
                          widget.group.id);
                      clearControllers();
                      Navigator.of(context).pop();
                      _fetchMeetings();
                    }
                  },
                  onNo: () {
                    clearControllers();
                    Navigator.of(context).pop();
                  },
                  yes: "Create",
                  no: "Cancel",
                )
              ],
            );
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
                  fetchMeetings: AppState.groupController.fetchGroupMeetings),
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
                      final link = await AppState.groupController.shareInviteLink(widget.group.id);
                      Share.share(link);
                    },
                  ),
                  CircleAvatar(
                    radius: 52.0,
                    backgroundColor: Colors.grey[300],
                    child: const Icon(
                      Icons.group,
                      size: 40.0,
                      color: Colors.white,
                    ),
                  ),
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
                  '${users.length} Members',
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
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => SchedulePage(
                                isGroupSchedule: true,
                                ownerId: widget.group.id,
                                ownerName: widget.group.name)));
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
                fetchMeetings: AppState.groupController.fetchGroupMeetings,
              );
            } else if (meetings[index].status == MeetingStatus.accepted) {
              return AcceptedMeetingTile(
                meeting: meetings[index],
                fetchMeetings: AppState.groupController.fetchGroupMeetings,
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
                  leading: const CircleAvatar(
                    backgroundColor: darkBlue,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
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
