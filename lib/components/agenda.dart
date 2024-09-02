import 'package:flutter/material.dart';
import 'package:coordimate/components/appbar.dart';
import 'package:coordimate/components/colors.dart';
import 'package:coordimate/models/agenda_point.dart';
import 'package:coordimate/app_state.dart';

const maxIndentLevel = 3;

class AgendaPointWidget extends StatefulWidget {
  const AgendaPointWidget(
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
  State<AgendaPointWidget> createState() => AgendaPointWidgetState();
}

class AgendaPointWidgetState extends State<AgendaPointWidget> {
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
                    IconButton(
                        onPressed: () {
                          setState(() {
                            widget.deletePoint(widget.index);
                          });
                        },
                        icon: const Icon(Icons.delete, color: orange))
                ]));
          },
        ));
  }
}

class MeetingAgenda extends StatefulWidget {
  const MeetingAgenda({super.key, required this.meetingId});

  final String meetingId;

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
    agenda = await AppState.meetingController.getAgendaPoints(widget.meetingId);
    return agenda;
  }

  Future<void> createAgendaPoint(String text, int level) async {
    await AppState.meetingController
        .createAgendaPoint(widget.meetingId, text, level);
    setState(() {
      _agendaPoints = getAgendaPoints();
    });
  }

  Future<void> deleteAgendaPoint(int index) async {
    await AppState.meetingController.deleteAgendaPoint(widget.meetingId, index);
    setState(() {
      _agendaPoints = getAgendaPoints();
    });
  }

  Future<void> updateAgenda() async {
    await AppState.meetingController.updateAgenda(widget.meetingId, agenda);
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
                      AgendaPointWidget(
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
