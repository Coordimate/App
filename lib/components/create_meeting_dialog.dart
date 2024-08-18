import 'package:flutter/material.dart';

import 'package:another_flushbar/flushbar.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:intl/intl.dart';

import 'package:coordimate/components/colors.dart';
import 'package:coordimate/components/pop_up_dialog.dart';
import 'package:coordimate/components/login_button.dart';
import 'package:coordimate/app_state.dart';

class CreateMeetingDialog extends StatefulWidget {
  final String groupId;
  final DateTime? pickedDate;

  //ToDo: understand whatever this blue line means here
  const CreateMeetingDialog(
      {super.key, required this.groupId, this.pickedDate});

  @override
  CreateMeetingDialogState createState() => CreateMeetingDialogState();
}

class CreateMeetingDialogState extends State<CreateMeetingDialog> {
  late DateTime selectedDate = (widget.pickedDate != null)
      ? widget.pickedDate!
      : DateTime.now().add(const Duration(minutes: 10));
  Duration selectedDuration = const Duration(minutes: 60);

  var formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
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
        selectedDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          selectedDate.hour,
          selectedDate.minute,
        );
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDate),
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
        selectedDate = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  Future<void> _setDuration() async {
    final Duration? pickedDuration = await showDurationPicker(
      context: context,
      initialTime: selectedDuration,
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
        selectedDuration = Duration(
            hours: pickedDuration.inHours,
            minutes: pickedDuration.inMinutes.remainder(60));
      });
    }
  }

  void clearControllers() {
    titleController.clear();
    descriptionController.clear();
    selectedDate = DateTime.now().add(const Duration(minutes: 10));
    selectedDuration = const Duration(minutes: 60);
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

  @override
  Widget build(BuildContext context) {
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
                  key: formKey,
                  child: TextFormField(
                    controller: titleController,
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
                      .format(selectedDate.toLocal())
                      .toString(),
                  onTap: () async {
                    await _selectDate();
                    setState(() {});
                  },
                ),
                const SizedBox(height: 16),
                LoginEmptyButton(
                  text: DateFormat('HH:mm')
                      .format(selectedDate.toLocal())
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
                  text: _printDuration(selectedDuration),
                  onTap: () async {
                    await _setDuration();
                    setState(() {});
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
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
              onYes: () async {
                if (formKey.currentState!.validate() == false) {
                  return;
                }
                if (selectedDate
                    .isBefore(DateTime.now().add(const Duration(minutes: 5)))) {
                  Flushbar(
                    message: 'Meeting needs to be at least in 5 minutes',
                    backgroundColor: orange,
                    duration: const Duration(seconds: 2),
                    flushbarPosition: FlushbarPosition.TOP,
                  ).show(context);
                } else {
                  await AppState.meetingController.createMeeting(
                      titleController.text,
                      selectedDate.toIso8601String(),
                      descriptionController.text,
                      widget.groupId);
                  clearControllers();
                  Navigator.of(context).pop();
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
  }
}
