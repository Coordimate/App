import 'package:flutter/material.dart';
import 'package:coordimate/components/colors.dart';
import 'package:intl/intl.dart';

class CalendarDayBox extends StatefulWidget {
  final DateTime date;
  final bool isSelected;
  // final void onDateSelected;

  const CalendarDayBox({
    super.key,
    required this.date,
    required this.isSelected,
    // required this.onDateSelected,
  });

  void onDateSelectedDefault() {
  }

  @override
  State<CalendarDayBox> createState() => _CalendarDayBoxState();
}

class _CalendarDayBoxState extends State<CalendarDayBox> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double boxWidth = screenWidth / 5 * 0.85; // Subtracting 20 to account for padding/margin
    return GestureDetector(
      onTap: () {
        // widget.onDateSelected(widget.date);
      },
      child: Container(
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
      ),
    );
  }
}
