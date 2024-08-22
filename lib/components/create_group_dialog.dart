import 'package:coordimate/components/pop_up_dialog.dart';
import 'package:flutter/material.dart';
import 'package:coordimate/widget_keys.dart';
import 'package:coordimate/components/colors.dart';

class CreateGroupDialog extends StatefulWidget {
  final Future<void> Function(String name, String description) onCreateGroup;
  final Future<void> Function() fetchGroups;

  const CreateGroupDialog(
      {super.key, required this.onCreateGroup, required this.fetchGroups});

  @override
  CreateGroupDialogState createState() => CreateGroupDialogState();
}

class CreateGroupDialogState extends State<CreateGroupDialog> {

  var formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  void clearControllers() {
    titleController.clear();
    descriptionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 0,
      title: const Center(child: Text('Create Group')),
      titleTextStyle: const TextStyle(
        color: darkBlue,
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
      alignment: Alignment.center,
      backgroundColor: Colors.white,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Form(
              key: formKey,
              child: TextFormField(
                key: groupCreationNameFieldKey,
                controller: titleController,
                maxLength: 20,
                style: const TextStyle(color: darkBlue),
                decoration: const InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: darkBlue),
                  hintText: 'Enter the name of the group',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: darkBlue),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: darkBlue, width: 2.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: descriptionController,
              style: const TextStyle(color: darkBlue),
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter the description of the group',
                labelStyle: TextStyle(color: darkBlue),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: darkBlue),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: darkBlue, width: 2.0),
                ),
              ),
              maxLines: null,
              maxLength: 100,
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
            await widget.onCreateGroup(titleController.text, descriptionController.text);
            clearControllers();
            if (context.mounted) {
              widget.fetchGroups();
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
  }
}