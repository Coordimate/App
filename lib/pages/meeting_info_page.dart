import 'package:coordimate/components/appbar.dart';
import 'package:flutter/material.dart';
import 'package:coordimate/components/colors.dart';
import 'package:coordimate/models/meeting.dart';
import 'package:coordimate/api_client.dart';
import 'package:coordimate/keys.dart';
import 'dart:convert';


class MeetingDetailsPage extends StatefulWidget {
  final MeetingDetails meeting;

  const MeetingDetailsPage({super.key, required this.meeting});

  @override
  State<MeetingDetailsPage> createState() => _MeetingDetailsPageState();
}

class _MeetingDetailsPageState extends State<MeetingDetailsPage> {

  Future<void> _answerInvitation(String id, bool accept) async {
    String status = 'accepted';
    if (!accept) {
      status = 'declined';
    }
    final response = await client.patch(
        Uri.parse("$apiUrl/invites/$id"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(<String, dynamic>{
          'status': status,
        })
    );
    if (!mounted) {return;}
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Meeting $status")),
      );
      setState(() {
        widget.meeting.status = accept ? MeetingStatus.accepted : MeetingStatus.declined;
      });
    } else {
      throw Exception('Failed to answer invitation');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
          title: '',
          needButton: false
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        child: SingleChildScrollView(
          child: Column( 
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.meeting.title,
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: darkBlue),
              ),
              if (widget.meeting.description.isNotEmpty)
                const SizedBox(height: 16),
              if (widget.meeting.description.isNotEmpty)
                Text(
                  widget.meeting.description,
                  style: const TextStyle(fontSize: 20, color: darkBlue),
                ),
          
              const SizedBox(height: 16),
          
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: darkBlue, width: 5),
                ),
                child: Column(
                  children: <Widget>[
                    buildInfoRow(Icons.calendar_today, "Date", widget.meeting.getFormattedDate()),
                    buildInfoRow(Icons.access_time, "Time", widget.meeting.getFormattedTime()),
                    buildInfoRow(Icons.group, "Group", widget.meeting.groupName),
                    buildInfoRow(Icons.person, "Host", widget.meeting.admin.username)
                  ],
                ),
              ),
          
              const SizedBox(height: 8),
          
              if (widget.meeting.status == MeetingStatus.accepted)
                TextField(
                  decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: alphaDarkBlue,
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: darkBlue,
                        ),
                      ),
                      hintText: 'Insert link or address here',
                      hintStyle: TextStyle(color: alphaDarkBlue),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            onPressed: (){},
                            icon: const Icon(Icons.copy),
                            color: darkBlue,
                          ),
                          IconButton(
                            onPressed: (){},
                            icon: const Icon(Icons.share),
                            color: darkBlue,
                          ),
                        ],
                      )
                  ),
                ),
          
              const SizedBox(height: 10),
          
              if (widget.meeting.status == MeetingStatus.accepted)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (){},
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(darkBlue),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),),
                    ),
                    child: const Text("Meeting Agenda", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
          
              if (widget.meeting.status == MeetingStatus.accepted)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (){},
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(mediumBlue),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),),
                    ),
                    child: const Text("Finish Meeting", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
          
          
              if (widget.meeting.status == MeetingStatus.needsAcceptance)
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    answerButton("Accept", lightBlue, () => _answerInvitation(widget.meeting.id, true)),
                    const SizedBox(width: 16),
                    answerButton("Decline", orange, () => _answerInvitation(widget.meeting.id, false)),
                  ],
                ),
          
              if (widget.meeting.status == MeetingStatus.declined)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (){},
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.grey),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),),
                    ),
                    child: const Text("Invitation Declined", style: TextStyle(fontSize: 20, color: darkBlue, fontWeight: FontWeight.bold)),
                  ),
                ),
          
              const SizedBox(height: 16),
          
              const Text(
                "Participants",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkBlue),
              ),
              Column(
                children: widget.meeting.participants.map((participant) {
                  return ListTile(
                    leading: CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text(participant.username, style: const TextStyle(color: darkBlue)),
                    subtitle: Text(participant.status, style: TextStyle(color: alphaDarkBlue)),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: <Widget>[
        Icon(icon),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 20, color: darkBlue)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 20, color: darkBlue, fontWeight: FontWeight.w600),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget answerButton(String text, Color color, Future<void> Function() onPressed){
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(color),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        child: Text(text, style: const TextStyle(color: darkBlue, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
    );
  }
}