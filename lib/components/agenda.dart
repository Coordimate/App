import 'package:flutter/material.dart';
import 'package:coordimate/components/appbar.dart';
import 'package:coordimate/components/colors.dart';

class AgendaPoint {
  AgendaPoint({required this.level, required this.text});

  int level = 0;
  // Internal! Used to animate indentation
  late int prevLevel = level;
  String text = "";
}

class _AgendaPointWidget extends StatefulWidget {
  const _AgendaPointWidget(
      {required super.key,
      required this.index,
      required this.agendaPoint,
      required this.indent});

  final fontSize = 20.0;
  final int index;
  final AgendaPoint agendaPoint;
  final void Function(int, int) indent;

  @override
  State<_AgendaPointWidget> createState() => _AgendaPointWidgetState();
}

class _AgendaPointWidgetState extends State<_AgendaPointWidget> {
  int swipeDirection = 0;
  Color bgColor = Colors.white;
  bool takingInput = false;
  late int prevIndentLevel = widget.agendaPoint.level;

  final textController = TextEditingController();

  void storeEdit(event) {
    setState(() {
      widget.agendaPoint.text = textController.text;
      takingInput = !takingInput;
    });
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
        onPanEnd: (details) {
          setState(() {
            prevIndentLevel = widget.agendaPoint.level;
            widget.indent(widget.index, swipeDirection);
            swipeDirection = 0;
            bgColor = Colors.white;
          });
        },
        child: TweenAnimationBuilder(
          tween: Tween<double>(
              begin: widget.agendaPoint.prevLevel.toDouble(),
              end: widget.agendaPoint.level.toDouble()),
          duration: const Duration(milliseconds: 200),
          builder: (context, double indentLevel, child) {
            // Update prevLevel once the Animation has played out
            widget.agendaPoint.prevLevel = widget.agendaPoint.level;

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
                      textController.text = widget.agendaPoint.text;
                      return TextField(
                        autofocus: true,
                        controller: textController,
                        onTapOutside: storeEdit,
                        onChanged: (event) {
                          setState(() {
                            widget.agendaPoint.text = textController.text;
                          });
                        },
                        maxLines: null,
                        style: TextStyle(
                          fontSize: widget.fontSize,
                          color: darkBlue,
                        ),
                      );
                    } else {
                      return Text(
                        widget.agendaPoint.text,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: widget.fontSize,
                          color: darkBlue,
                        ),
                      );
                    }
                  }))
                ]));
          },
        ));
  }
}

class MeetingAgenda extends StatefulWidget {
  const MeetingAgenda({super.key});

  @override
  State<MeetingAgenda> createState() => MeetingAgendaState();
}

class MeetingAgendaState extends State<MeetingAgenda> {
  final maxIndentLevel = 3;

  // TODO: temporary measure for testing
  List<AgendaPoint> agenda = [
    AgendaPoint(
        level: 0,
        text:
            'hello, this is a really long agenda point that would never fit on the screen'),
    AgendaPoint(level: 0, text: 'hello 1'),
    AgendaPoint(level: 1, text: 'hello 2'),
    AgendaPoint(level: 1, text: 'hello 3'),
    AgendaPoint(level: 2, text: 'hello 4'),
    AgendaPoint(level: 0, text: 'hello 5'),
  ];

  void indentPoint(int index, int indentDirection) {
    setState(() {
      agenda[index].prevLevel = agenda[index].level;
      agenda[index].level += indentDirection;
      if (agenda[index].level < 0) {
        agenda[index].level = 0;
      } else if (agenda[index].level > maxIndentLevel) {
        agenda[index].level = maxIndentLevel;
      }
    });
  }

  // TODO: move the children along when indenting
  void indentWithChildren(int index, int indentDirection) {
    int i = index + 1;
    while (i < agenda.length && agenda[i].level > agenda[index].level) {
      indentPoint(i, indentDirection);
      i++;
    }
    indentPoint(index, indentDirection);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: const CustomAppBar(title: 'Agenda', needButton: false),
        body: ReorderableListView(
          children: [
            for (int index = 0; index < agenda.length; index += 1)
              _AgendaPointWidget(
                  key: UniqueKey(),
                  index: index,
                  agendaPoint: agenda[index],
                  indent: indentPoint),
          ],
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              AgendaPoint item = agenda.removeAt(oldIndex);
              agenda.insert(newIndex, item);

              // Avoid indent animation when reordering list items
              for (final ap in agenda) {
                ap.prevLevel = ap.level;
              }
              // TODO: Move the children along on reorder (lacking animation)
              // int level = agenda[newIndex].level;
              // int i = oldIndex + 1;
              // int j = 1;
              // if (oldIndex < newIndex) {
              //   i -= 1;
              //   j -= 1;
              // }
              // while (i < agenda.length && agenda[i].level > level) {
              //   item = agenda.removeAt(i);
              //   if (newIndex + j > agenda.length) {
              //     agenda.add(item);
              //   } else {
              //     agenda.insert(newIndex + j, item);
              //   }
              //   if (oldIndex > newIndex) {
              //     i += 1;
              //     j += 1;
              //   }
              // }
            });
          },
        ));
  }
}