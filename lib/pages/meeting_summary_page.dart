import 'package:coordimate/components/appbar.dart';
import 'package:coordimate/components/colors.dart';
import 'package:flutter/material.dart';

class SummaryPage extends StatefulWidget {
  final String summary;

  const SummaryPage({
    super.key,
    this.summary = '',
  });

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  var summaryController = TextEditingController();
  FocusNode focusNode = FocusNode();
  double fontSize = 16.0; // Initial font size

  @override
  void initState() {
    super.initState();
    summaryController.text = widget.summary;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(focusNode);
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.white,
            body: Padding(
              padding: EdgeInsets.only(top: 120.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Icon(Icons.text_fields, color: darkBlue),
                        Expanded(
                            child: Slider(
                              value: fontSize,
                              min: 10.0,
                              max: 30.0,
                              activeColor: darkBlue,
                              onChanged: (newSize) {
                                setState(() {
                                  fontSize = newSize;
                                });
                              },
                            ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        focusNode: focusNode,
                        controller: summaryController,
                        maxLines: null,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter summary of the meeting...',
                        ),
                        style: TextStyle(
                          fontSize: fontSize,
                          color: darkBlue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: CustomAppBar(
                title: 'Meeting Summary',
                needButton: false
            ),
          ),
        ],
      ),
    );
  }
}