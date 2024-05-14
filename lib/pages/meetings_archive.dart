import 'package:coordimate/components/appbar.dart';
import 'package:flutter/material.dart';

class MeetingsArchivePage extends StatefulWidget {
  const MeetingsArchivePage({super.key});

  @override
  State<MeetingsArchivePage> createState() => _MeetingsArchivePageState();
}

class _MeetingsArchivePageState extends State<MeetingsArchivePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: 'Archive',
          needButton: false
      ),
      body: const Center(
        child: Text('Meetings Archive'),
      ),
    );
  }
}