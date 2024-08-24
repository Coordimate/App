import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:coordimate/components/appbar.dart';
import 'package:coordimate/components/colors.dart';
import 'package:coordimate/models/groups.dart';
import 'package:coordimate/app_state.dart';

class CreateGroupPollPage extends StatefulWidget {
  final String groupId;

  const CreateGroupPollPage({super.key, required this.groupId});

  @override
  State<CreateGroupPollPage> createState() => _CreateGroupPollPageState();
}

class _CreateGroupPollPageState extends State<CreateGroupPollPage> {
  final questionController = TextEditingController();

  List<TextEditingController> optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  void addOption() {
    setState(() {
      optionControllers.add(TextEditingController());
    });
  }

  void createPoll() {
    final pollData = json.encode({
      "question": questionController.text,
      "options": optionControllers.map((con) => con.text).toList(),
    });
    AppState.groupController.createPoll(widget.groupId, pollData);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: CustomAppBar(
          title: "Create Poll", needButton: true, onPressed: addOption),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          TextFormField(
              controller: questionController,
              decoration: const InputDecoration(
                  hintStyle: TextStyle(color: gridGrey),
                  hintText: 'Which do you prefer?',
                  labelText: 'Question')),
          const Text("Options:"),
          Expanded(
            child: ListView.builder(
                itemCount: optionControllers.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                      key: UniqueKey(),
                      background: Container(color: Colors.red),
                      onDismissed: (direction) {
                        setState(() {
                          optionControllers.removeAt(index);
                        });
                      },
                      child: TextFormField(
                          controller: optionControllers[index],
                          decoration: const InputDecoration(
                              hintStyle: TextStyle(color: gridGrey),
                              hintText: 'Some option')));
                }),
          )
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createPoll,
        backgroundColor: darkBlue,
        foregroundColor: white,
        child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            child: Icon(Icons.send_outlined)),
      ),
    );
  }
}

class GroupPollCard extends StatefulWidget {
  final String groupId;
  final GroupPoll? initialPoll;
  final bool isAdmin;
  final double fontSize;

  const GroupPollCard(
      {super.key,
      required this.groupId,
      required this.initialPoll,
      required this.fontSize,
      this.isAdmin = false});

  @override
  State<GroupPollCard> createState() => _GroupPollCardState();
}

class _GroupPollCardState extends State<GroupPollCard> {
  late GroupPoll? poll = widget.initialPoll;

  late final Widget baseCard = Padding(
    padding: const EdgeInsets.all(8.0),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkBlue,
      ),
      onPressed: () {},
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            children: [
              Text(
                "Active Group Poll",
                style: TextStyle(
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.bold,
                  color: white,
                ),
              ),
              Text(
                poll!.question,
                style: TextStyle(
                  fontSize: widget.fontSize,
                  color: white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (poll == null && widget.isAdmin) {
      return TextButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    CreateGroupPollPage(groupId: widget.groupId))).then((_) async {
                      var newPoll = await AppState.groupController.fetchPoll(widget.groupId);
                      setState(() {
                        poll = newPoll;
                      });
            });

          },
          child: const Text(
            'Create a Group Poll',
            style: TextStyle(
                color: darkBlue, fontSize: 20, fontWeight: FontWeight.w700),
          ));
    } else if (poll != null && widget.isAdmin) {
      return Dismissible(
          key: UniqueKey(),
          background: Container(color: Colors.red),
          onDismissed: (_) {
            AppState.groupController.deletePoll(widget.groupId);
            setState(() {
              poll = null;
            });
          },
          child: baseCard);
    } else if (poll != null) {
      return baseCard;
    } else {
      return Container();
    }
  }
}
