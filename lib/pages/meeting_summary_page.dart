// ignore_for_file: deprecated_member_use

import 'package:coordimate/components/appbar.dart';
import 'package:coordimate/components/colors.dart';
import 'package:flutter/material.dart';
import 'package:coordimate/app_state.dart';
import 'package:coordimate/widget_keys.dart';

class SummaryPage extends StatefulWidget {
  final String summary;
  final String id;

  const SummaryPage({
    super.key,
    required this.id,
    this.summary = '',
  });

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  var summaryController = TextEditingController();
  FocusNode focusNode = FocusNode();
  double fontSize = 16.0;
  String initialSummary = '';

  @override
  void initState() {
    super.initState();
    initialSummary = widget.summary;
    summaryController.text = widget.summary;
  }

  Future<void> _saveSummary() async {
    if (summaryController.text.isEmpty ||
        summaryController.text == initialSummary) {
      return;
    }
    await AppState.meetingController
        .saveSummary(widget.id, summaryController.text);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(focusNode);
      },
      child: PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) async {
          if (didPop) {
            return;
          }
          await _saveSummary();
          if (context.mounted) {
            Navigator.pop(context);
          }
        },
        child: Stack(
          children: [
            Scaffold(
              backgroundColor: Colors.white,
              body: Padding(
                padding: const EdgeInsets.only(top: 120.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.text_fields, color: darkBlue),
                          Expanded(
                            child: Slider(
                              key: sliderKey,
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
                          key: summaryTextFieldKey,
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
            Positioned(
              top: 0.0,
              left: 0.0,
              right: 0.0,
              child: CustomAppBar(
                title: 'Summary',
                needButton: true,
                buttonIcon: Icons.check,
                onPressed: _saveSummary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
