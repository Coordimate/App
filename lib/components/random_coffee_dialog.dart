import 'package:coordimate/models/user.dart';
import 'package:flutter/material.dart';

import 'package:another_flushbar/flushbar.dart';

import 'package:coordimate/components/colors.dart';
import 'package:coordimate/components/pop_up_dialog.dart';
import 'package:coordimate/components/login_button.dart';
import 'package:coordimate/app_state.dart';

class RandomCoffeeDialog extends StatefulWidget {
  final RandomCoffee randomCoffee;

  const RandomCoffeeDialog({super.key, required this.randomCoffee});

  @override
  RandomCoffeeDialogState createState() => RandomCoffeeDialogState();
}

class RandomCoffeeDialogState extends State<RandomCoffeeDialog> {
  late TimeOfDay startTime =
      widget.randomCoffee.startTime ?? const TimeOfDay(hour: 10, minute: 0);
  late TimeOfDay endTime =
      widget.randomCoffee.endTime ?? const TimeOfDay(hour: 18, minute: 0);
  late bool randomCoffeeEnabled = widget.randomCoffee.isEnabled;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  Future<void> _selectTime({required bool isStart}) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: isStart ? startTime : endTime,
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
      if (isStart) {
        setState(() {
          startTime = pickedTime;
        });
      } else {
        setState(() {
          endTime = pickedTime;
        });
      }
    }
  }

  void clearControllers() {
    setState(() {
      startTime = const TimeOfDay(hour: 10, minute: 0);
      endTime = const TimeOfDay(hour: 18, minute: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return AlertDialog(
          elevation: 0,
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_cafe, color: darkBlue, size: 24),
              SizedBox(width: 8),
              Text(
                "Random Coffee",
                style: TextStyle(
                    color: darkBlue,
                    fontSize: 24),
              ),
            ],
          ),
          titleTextStyle: const TextStyle(
            color: darkBlue,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
          alignment: Alignment.center,
          backgroundColor: Colors.white,
          content: SingleChildScrollView(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: ListBody(
                children: <Widget>[
                  if (!randomCoffeeEnabled)
                    const Text(
                        'The feature is disabled. Toggle the switch to participate.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: darkBlue,
                          fontSize: 18,
                        )),
                  Switch(
                      value: randomCoffeeEnabled,
                      activeColor: mediumBlue,
                      onChanged: (value) {
                        setState(() {
                          randomCoffeeEnabled = value;
                        });
                      }),
                  if (randomCoffeeEnabled) ...[
                    const Text(
                        'Pick a daily time interval, when you are free to meet up for Random Coffee',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: darkBlue,
                          fontSize: 18,
                        )),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text('Starting from',
                          style: TextStyle(
                            color: darkBlue,
                            fontSize: 18,
                          )),
                    ),
                    LoginEmptyButton(
                      text: startTime.format(context),
                      onTap: () async {
                        await _selectTime(isStart: true);
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text('Up to',
                          style: TextStyle(
                            color: darkBlue,
                            fontSize: 18,
                          )),
                    ),
                    LoginEmptyButton(
                      text: endTime.format(context),
                      onTap: () async {
                        await _selectTime(isStart: false);
                        setState(() {});
                      },
                    )
                  ],
                ],
              ),
            ),
          ),
          actions: <Widget>[
            ConfirmationButtons(
              onYes: () async {
                if (60 * startTime.hour + startTime.minute >=
                    60 * endTime.hour + endTime.minute) {
                  Flushbar(
                    message:
                        'Start time of the interval must be earlier than the end time',
                    backgroundColor: orange,
                    duration: const Duration(seconds: 2),
                    flushbarPosition: FlushbarPosition.TOP,
                  ).show(context);
                } else {
                  await AppState.userController.updateRandomCoffee(
                      AppState.authController.userId,
                      RandomCoffee(
                              startTime: startTime,
                              endTime: endTime,
                              isEnabled: randomCoffeeEnabled)
                          .toJson());
                  clearControllers();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                }
              },
              onNo: () {
                clearControllers();
                Navigator.of(context).pop();
              },
              yes: "Save",
              no: "Cancel",
            )
          ],
        );
      },
    );
  }
}
