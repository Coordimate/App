import 'package:coordimate/components/appbar.dart';
import 'package:flutter/material.dart';
import 'package:coordimate/components/colors.dart';

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
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 15,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: darkBlue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            // contentPadding: const EdgeInsets.all(16),
            title: Row(
                  children: [
                    Text(
                      'Doggies Group',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: Colors.white
                      ),
                    ), // Title
                  ],
                ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Barking all day long with my friends!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Wednesday, September 20', // Add your additional line of text here
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.white70), // Calendar Icon
                    const SizedBox(width: 8), // Add spacing
                    Text(
                      'Doggies Group',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white70
                      ),
                    ), // Title
                  ],
                ),
              ],
            ),
            // trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to the meeting details page
            },
          ),
        );
      },
    );
  }
}

