import 'package:flutter/material.dart';
import 'package:coordimate/components/colors.dart';
import 'package:intl/intl.dart';

class CalendarDayBox extends StatefulWidget {
  final DateTime date;
  final bool isSelected;
  final Function(DateTime) onSelected;

  const CalendarDayBox({
    super.key,
    required this.date,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  State<CalendarDayBox> createState() => _CalendarDayBoxState();
}

class _CalendarDayBoxState extends State<CalendarDayBox> {
  // bool isSelected = false;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double boxWidth = screenWidth / 5 * 0.85; // Subtracting 20 to account for padding/margin
    return GestureDetector(
      onTap: () {
        setState(() {
          widget.onSelected(widget.date);
          // print(widget.date);
          // print(isSelected);
          // isSelected = !isSelected;
          // // isSelected = DateTime.now().day == widget.date.day;
          // print(isSelected);
        });
      },
      child: Builder(
        builder: (BuildContext context) {
          return Container(
            width: boxWidth,
            height: boxWidth,
            decoration: BoxDecoration(
              color: widget.isSelected ? mediumBlue : Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  double fontSize = constraints.maxHeight;
                  return FittedBox(
                    fit: BoxFit.contain,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            widget.date.day.toString(),
                            style: TextStyle(
                              color: widget.isSelected ? Colors.white : darkBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: fontSize,
                            ),
                          ),
                          Text(
                            DateFormat('EEE').format(widget.date),
                            style: TextStyle(
                              color: widget.isSelected ? Colors.white : darkBlue,
                              fontSize: fontSize * 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
            ),
          );
        }
      ),
    );
  }
}
