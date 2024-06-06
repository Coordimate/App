import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:coordimate/components/appbar.dart';
import 'package:coordimate/components/colors.dart';
import 'package:coordimate/models/agenda_point.dart';
import 'package:coordimate/keys.dart';
import 'package:coordimate/controllers/auth_controller.dart';

const maxIndentLevel = 3;

class _AgendaPointWidget extends StatefulWidget {
  const _AgendaPointWidget(
      {required super.key,
      required this.index,
      required this.text,
      required this.level,
      required this.indentPoint,
      required this.editPoint,
      required this.updateAgenda,
      required this.deletePoint});

  final fontSize = 20.0;
  final int index;
  final String text;
  final int level;
  final void Function(int, int) indentPoint;
  final void Function(int) deletePoint;
  final void Function(int, String) editPoint;
  final Future<void> Function() updateAgenda;

  @override
  State<_AgendaPointWidget> createState() => _AgendaPointWidgetState();
}

class _AgendaPointWidgetState extends State<_AgendaPointWidget> {
  int swipeDirection = 0;
  Color bgColor = Colors.white;
  late String text = widget.text;
  late int level = widget.level;

  bool showDelete = false;
  late int prevLevel = level;
  late bool takingInput = text == '';

  final textController = TextEditingController();

  void storeEdit(event) async {
    setState(() {
      text = textController.text;
      takingInput = !takingInput;
      showDelete = false;
    });
    widget.editPoint(widget.index, text);
    await widget.updateAgenda();
  }

  @override
    void dispose() {
      textController.dispose();
      super.dispose();
    }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          setState(() {
            takingInput = !takingInput;
          });
        },
        onPanUpdate: (details) {
          if (details.delta.dx > 0) {
            setState(() {
              swipeDirection = 1;
            });
          }
          if (details.delta.dx < 0) {
            setState(() {
              swipeDirection = -1;
            });
          }
        },
        onPanEnd: (details) async {
          setState(() {
            widget.indentPoint(widget.index, swipeDirection);

            prevLevel = level;
            showDelete =
                (level == 0 && swipeDirection < 0 && showDelete == false);
            level += swipeDirection;
            if (level < 0) level = 0;
            if (level > maxIndentLevel) level = maxIndentLevel;

            swipeDirection = 0;
            bgColor = Colors.white;
          });
        },
        child: TweenAnimationBuilder(
          tween:
              Tween<double>(begin: prevLevel.toDouble(), end: level.toDouble()),
          duration: const Duration(milliseconds: 200),
          builder: (context, double indentLevel, child) {
            // Update prevLevel once the Animation has played out
            prevLevel = level;

            return Container(
                decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: const BorderRadius.all(Radius.circular(20))),
                margin: EdgeInsets.only(
                    left:
                        widget.fontSize + (1.5 * widget.fontSize * indentLevel),
                    right: widget.fontSize,
                    top: widget.fontSize / 4,
                    bottom: widget.fontSize / 4),
                child: Row(children: [
                  Icon(Icons.circle, size: widget.fontSize / 2),
                  SizedBox(width: widget.fontSize / 2),
                  Expanded(child: Builder(builder: (context) {
                    if (takingInput) {
                      textController.text = text;
                      return TextField(
                        autofocus: true,
                        controller: textController,
                        onTapOutside: storeEdit,
                        onSubmitted: storeEdit,
                        decoration: null,
                        style: TextStyle(
                          fontSize: widget.fontSize,
                          color: darkBlue,
                        ),
                      );
                    } else {
                      return Text(
                        text,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: widget.fontSize,
                          color: darkBlue,
                        ),
                      );
                    }
                  })),
                  if (showDelete)
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            widget.deletePoint(widget.index);
                          });
                        },
                        child: const Icon(Icons.delete, color: orange))
                ]));
          },
        ));
  }
}

class MeetingAgenda extends StatefulWidget {
  const MeetingAgenda({super.key, required this.authCon, required this.meetingId});

  final String meetingId;
  final AuthorizationController authCon;

  @override
  State<MeetingAgenda> createState() => MeetingAgendaState();
}

class MeetingAgendaState extends State<MeetingAgenda> {

  Future<List<AgendaPoint>>? _agendaPoints;

  @override
  void initState() {
    super.initState();
    _agendaPoints = getAgendaPoints();
  }

  List<AgendaPoint> agenda = [];

  Future<List<AgendaPoint>> getAgendaPoints() async {
    final response = await widget.authCon.client.get(
        Uri.parse("$apiUrl/meetings/${widget.meetingId}/agenda"),
        headers: {"Content-Type": "application/json"});
    final List body = json.decode(response.body)["agenda"];
    agenda = body.map((e) => AgendaPoint.fromJson(e)).toList();
    return agenda;
  }

  Future<void> createAgendaPoint(String text, int level) async {
    await widget.authCon.client.post(Uri.parse("$apiUrl/meetings/${widget.meetingId}/agenda"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(<String, dynamic>{
          'text': text,
          'level': level,
        }));
    setState(() {
      _agendaPoints = getAgendaPoints();
    });
  }

  Future<void> deleteAgendaPoint(int index) async {
    await widget.authCon.client.delete(
        Uri.parse("$apiUrl/meetings/${widget.meetingId}/agenda/$index"),
        headers: {"Content-Type": "application/json"});
    setState(() {
      _agendaPoints = getAgendaPoints();
    });
  }

  Future<void> updateAgenda() async {
    await widget.authCon.client.patch(Uri.parse("$apiUrl/meetings/${widget.meetingId}/agenda"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(<String, dynamic>{
          'agenda':
              agenda.map((ap) => {'text': ap.text, 'level': ap.level}).toList(),
        }));
    setState(() {
      _agendaPoints = getAgendaPoints();
    });
  }

  void indentPoint(int index, int indentDirection) async {
    setState(() {
      agenda[index].level += indentDirection;
      if (agenda[index].level < 0) {
        agenda[index].level = 0;
      } else if (agenda[index].level > maxIndentLevel) {
        agenda[index].level = maxIndentLevel;
      }
    });
    await updateAgenda();
  }

  void editPoint(int index, String text) {
    setState(() {
      agenda[index].text = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
            title: 'Agenda',
            needButton: true,
            onPressed: () {
              createAgendaPoint('', 0);
            }),
        body: FutureBuilder(
            future: _agendaPoints,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ReorderableListView(
                  children: [
                    for (int index = 0;
                        index < snapshot.data!.length;
                        index += 1)
                      _AgendaPointWidget(
                          // key: Key(snapshot.data![index].text),
                          key: Key(
                              snapshot.data![index].text + index.toString()),
                          index: index,
                          text: snapshot.data![index].text,
                          level: snapshot.data![index].level,
                          editPoint: editPoint,
                          indentPoint: indentPoint,
                          updateAgenda: updateAgenda,
                          deletePoint: deleteAgendaPoint),
                  ],
                  onReorder: (int oldIndex, int newIndex) async {
                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      AgendaPoint item = agenda.removeAt(oldIndex);
                      agenda.insert(newIndex, item);
                    });
                    await updateAgenda();
                  },
                );
              } else {
                return const CircularProgressIndicator();
              }
            }));
  }
}
