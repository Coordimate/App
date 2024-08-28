import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:coordimate/components/appbar.dart';
import 'package:coordimate/components/colors.dart';
import 'package:coordimate/components/avatar.dart';
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
  var formKey = GlobalKey<FormState>();

  List<TextEditingController> optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  void addOption() {
    setState(() {
      optionControllers.add(TextEditingController());
    });
  }

  void createPoll() async {
    if (formKey.currentState!.validate() == false) {
      return;
    }
    final pollData = json.encode({
      "question": questionController.text,
      "options": optionControllers.map((con) => con.text).toList(),
    });

    await AppState.groupController.createPoll(widget.groupId, pollData);
    if (mounted) {
      Navigator.pop(context, pollData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: const CustomAppBar(title: "Create Poll", needButton: false),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: formKey,
          child: Column(children: [
            QuestionTextField(controller: questionController),
            const SizedBox(height: 24),
            const Text("Options",
                style: TextStyle(
                    color: darkBlue,
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                )
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: optionControllers.length + 1,
                  itemBuilder: (context, index) {
                    if (index == optionControllers.length) {
                      return AddOptionButton(onAddOption: addOption);
                    }
                    return PollTextField(
                      controller: optionControllers[index],
                      hintText: 'Option ${index + 1}',
                      onPressed: () {
                        setState(() {
                          optionControllers.removeAt(index);
                        });
                      },
                      areTwoLeft: optionControllers.length > 2,
                    );
                  }),
            ),
          ]),
        ),
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

class QuestionTextField extends StatelessWidget {
  final TextEditingController controller;

  const QuestionTextField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: darkBlue,
        border: Border.all(color: darkBlue, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 20),
        decoration: const InputDecoration(
          hintText: 'Question',
          hintStyle: TextStyle(color: Colors.white70),
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder:UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          errorStyle: TextStyle(color: Colors.white),
        ),
        maxLines: null,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a question';
          }
          return null;
        },
      ),
    );
  }
}

class AddOptionButton extends StatelessWidget {
  final VoidCallback onAddOption;

  const AddOptionButton({
    super.key,
    required this.onAddOption,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAddOption,
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.add_circle_outline, color: darkBlue, size: 20),
              SizedBox(width: 16),
              Text(
                "Add Option",
                style: TextStyle(
                    color: darkBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PollTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback onPressed;
  final bool areTwoLeft;

  const PollTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onPressed,
    this.areTwoLeft = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: darkBlue),
      decoration: InputDecoration(
        hintText: hintText,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: darkBlue),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: darkBlue, width: 2.0),
        ),
        suffixIcon:  IconButton(
          icon: Icon(Icons.clear, color: areTwoLeft ? darkBlue : Colors.white),
          onPressed: areTwoLeft ? onPressed : null,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter an option';
        }
        return null;
      },
    );
  }
}

class VoteGroupPollPage extends StatefulWidget {
  final String groupId;
  final GroupPoll poll;
  final Map<String, Avatar> memberAvatars;

  const VoteGroupPollPage(
      {super.key,
        required this.groupId,
        required this.poll,
        required this.memberAvatars});

  @override
  State<VoteGroupPollPage> createState() => _VoteGroupPollPageState();
}

class _VoteGroupPollPageState extends State<VoteGroupPollPage> {
  late GroupPoll poll = widget.poll;
  int voteCount = 0;

  @override
  void initState() {
    super.initState();
    if (widget.poll.votes != null) {
      for (int i = 0; i < widget.poll.options.length; i++) {
        voteCount += widget.poll.votes![i]!.length;
      }
    }
  }

  Future<void> placeVote(optionIndex) async {
    await AppState.groupController.voteOnPoll(widget.groupId, optionIndex);
    setState(() {
      if (poll.votes == null) {
        poll.votes = {};
        for (int i = 0; i < poll.options.length; i++) {
          poll.votes![i] = [];
        }
      }
      for (int i = 0; i < poll.options.length; i++) {
        if (poll.votes![i]!.contains(AppState.authController.userId)) {
          poll.votes![i]!.remove(AppState.authController.userId);
          voteCount--;
        }
      }
      poll.votes![optionIndex]!.add(AppState.authController.userId!);
      voteCount++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: const CustomAppBar(title: "Group Poll", needButton: false),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.poll.question, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Text('$voteCount vote${voteCount == 1 ? '' : 's'} to go',
                style: const TextStyle(color: Colors.grey)),
          ]),
          Expanded(
              child: ListView.builder(
                  itemCount: widget.poll.options.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                        onTap: () async {
                          await placeVote(index);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: darkBlue,
                              borderRadius: BorderRadius.circular(10)),
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(widget.poll.options[index],
                                        softWrap: true,
                                        style: const TextStyle(
                                            color: white, fontSize: 18)),
                                  ),
                                  if (widget.poll.votes != null)
                                    Wrap(spacing: -20, children: [
                                      ...widget.poll.votes![index]!
                                          .getRange(
                                          0,
                                          math.min(
                                              widget.poll.votes![index]!
                                                  .length,
                                              3))
                                          .map((userId) =>
                                      widget.memberAvatars[userId]!),
                                    ])
                                ],
                              ),
                              if (widget.poll.votes != null)
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                          'Votes: ${widget.poll.votes![index]!.length}',
                                          style:
                                          const TextStyle(color: lightBlue))
                                    ]),
                            ]),
                          ),
                        ));
                  })),
        ]),
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
  GroupPoll? poll;
  Future<GroupPoll?>? pollFuture;

  @override
  void initState() {
    super.initState();
    pollFuture = AppState.groupController.fetchPoll(widget.groupId);
  }

  void openVotePage() async {
    Map<String, Avatar> memberAvatars = {};
    var users = await AppState.groupController.fetchGroupUsers(widget.groupId);
    for (int i = 0; i < users.length; i++) {
      memberAvatars[users[i].id] = Avatar(size: 30, userId: users[i].id);
    }
    if (mounted) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => VoteGroupPollPage(
          groupId: widget.groupId,
          poll: poll!,
          memberAvatars: memberAvatars
        ),
      )).then((_) {
        pollFuture = AppState.groupController.fetchPoll(widget.groupId);
      });
    }
  }

  void openCreatePollPage() async {
    final pollData = await Navigator.push(context, MaterialPageRoute(
      builder: (context) => CreateGroupPollPage(groupId: widget.groupId),
    ));
    if (pollData != null) {
      final fetchedPoll = await AppState.groupController.fetchPoll(
          widget.groupId);
      setState(() {
        poll = fetchedPoll;
        pollFuture = AppState.groupController.fetchPoll(widget.groupId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: pollFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          poll = snapshot.data;
          if (poll == null && widget.isAdmin) {
            return CreateGroupPollButton(groupId: widget.groupId, onPressed: openCreatePollPage);
          } else if (poll != null && widget.isAdmin) {
            return Dismissible(
                key: UniqueKey(),
                background: Container(color: Colors.white70),
                onDismissed: (_) async {
                  await AppState.groupController.deletePoll(widget.groupId);
                  setState(() {
                    poll = null;
                    pollFuture = AppState.groupController.fetchPoll(widget.groupId);
                  });
                },
                child: ActiveGroupPollButton(
                  groupId: widget.groupId,
                  poll: poll!,
                  fontSize: widget.fontSize,
                  onPressed: openVotePage,
                ));
          } else if (poll != null) {
            return ActiveGroupPollButton(
              groupId: widget.groupId,
              poll: poll!,
              fontSize: widget.fontSize,
              onPressed: openVotePage,
            );
          } else {
            return Container();
          }
        } else {
          return const CircularProgressIndicator();
        }
      }
    );
  }
}

class CreateGroupPollButton extends StatelessWidget {
  final String groupId;
  final GestureTapCallback? onPressed;

  const CreateGroupPollButton({
    super.key,
    required this.groupId,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(4),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: mediumBlue,
          border: Border.all(color: mediumBlue, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Text(
            "Create Group Poll",
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
    );
  }
}

class ActiveGroupPollButton extends StatelessWidget {
  final String groupId;
  final GroupPoll poll;
  final double fontSize;
  final VoidCallback onPressed;

  const ActiveGroupPollButton({
    super.key,
    required this.groupId,
    required this.poll,
    required this.fontSize,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              children: [
                Text(
                  "Active Group Poll",
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: white,
                  ),
                ),
                Text(
                  poll.question,
                  style: TextStyle(
                    fontSize: fontSize,
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
  }
}