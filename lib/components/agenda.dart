import 'package:flutter/material.dart';
import 'package:coordimate/components/appbar.dart';
import 'package:coordimate/components/colors.dart';

class AgendaPoint {
  AgendaPoint({required this.level, required this.text});

  int level = 0;
  String text = "";
}

class _AgendaPointWidget extends StatefulWidget {
  const _AgendaPointWidget(
      {required this.index, required this.agendaPoint, required this.indent});

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
  final textController = TextEditingController();

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
            widget.indent(widget.index, swipeDirection);
            swipeDirection = 0;
            bgColor = Colors.white;
          });
        },
        onPanDown: (details) {
          setState(() {
            bgColor = lightBlue;
          });
        },
        child: Container(
            decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.all(Radius.circular(20))),
            margin: EdgeInsets.only(
                left: widget.fontSize +
                    (1.5 * widget.fontSize * widget.agendaPoint.level)
                        .toDouble(),
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
                    controller: textController,
                    onTapOutside: (event) {
                      setState(() {
                        widget.agendaPoint.text = textController.text;
                        takingInput = !takingInput;
                      });
                    },
                    maxLines: 3,
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
            ])));
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
    AgendaPoint(level: 0, text: 'hello'),
    AgendaPoint(level: 1, text: 'hello'),
    AgendaPoint(level: 1, text: 'hello'),
    AgendaPoint(level: 2, text: 'hello'),
    AgendaPoint(level: 0, text: 'hello'),
  ];

  void indentPoint(int index, int indentDirection) {
    setState(() {
      agenda[index].level += indentDirection;
      if (agenda[index].level < 0) {
        agenda[index].level = 0;
      } else if (agenda[index].level > maxIndentLevel) {
        agenda[index].level = maxIndentLevel;
      }
    });
  }

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
        body: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (var i = 0; i < agenda.length; i++)
            _AgendaPointWidget(
                index: i, agendaPoint: agenda[i], indent: indentWithChildren),
        ])));
  }
}
