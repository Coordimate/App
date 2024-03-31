import 'package:coordimate/components/appbar.dart';
import 'package:flutter/material.dart';
import 'package:coordimate/components/meeting_tiles.dart';

class MeetingsPage extends StatefulWidget {
  const MeetingsPage({
    super.key,
  });

  @override
  State<MeetingsPage> createState() => _MeetingsPageState();
}

class _MeetingsPageState extends State<MeetingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: "Meetings"),
      body: _buildListView(),
    );
  }

  ListView _buildListView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        ...List.generate(3, (index) => NewMeetingTile(
            title: "New Meeting $index blablabla",
            date: "Wed, September 20, 12:30",
            group: "Doggies Group"
        )),
        ...List.generate(2, (index) => AcceptedMeetingTile(
            title: "Accepted Meeting $index blablablabla",
            date: "Wed, September 20, 12:30",
            group: "Doggies Group"
        )),
        ...List.generate(3, (index) => ArchivedMeetingTile(
            title: "Archived Meeting $index blablablabla",
            date: "Wed, September 20, 12:30",
            group: "Doggies Group"
        )),
      ],
    );
  }
}

