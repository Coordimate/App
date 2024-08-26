import 'dart:convert';
import 'dart:math';
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
                                              min(
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
  late GroupPoll? poll = widget.initialPoll;

  late final Widget baseCard = Padding(
    padding: const EdgeInsets.all(8.0),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkBlue,
      ),
      onPressed: () async {
        Map<String, Avatar> memberAvatars = {};
        var users =
            await AppState.groupController.fetchGroupUsers(widget.groupId);
        for (int i = 0; i < users.length; i++) {
          memberAvatars[users[i].id] = Avatar(size: 30, userId: users[i].id);
        }

        if (context.mounted) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => VoteGroupPollPage(
                  groupId: widget.groupId,
                  poll: poll!,
                  memberAvatars: memberAvatars)));
        }
      },
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
      return
        GestureDetector(
          onTap: () {
            Navigator.of(context)
                .push(MaterialPageRoute(
                builder: (context) =>
                    CreateGroupPollPage(groupId: widget.groupId)))
                .then((_) async {
              var newPoll =
              await AppState.groupController.fetchPoll(widget.groupId);
              setState(() {
                poll = newPoll;
              });
            });
          },
          child: Container(
            padding: const EdgeInsets.all(4),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: darkBlue, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child:
              Text(
                "Create Group Poll",
                style: TextStyle(
                    color: darkBlue,
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),
        );
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
