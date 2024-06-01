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
              padding: const EdgeInsets.only(top: 110.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  focusNode: focusNode,
                  controller: summaryController,
                  maxLines: null,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter summary of the meeting...',
                    hintStyle: TextStyle(
                      fontSize: 16.0,
                      color: alphaDarkBlue,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: darkBlue,
                  ),
                ),
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