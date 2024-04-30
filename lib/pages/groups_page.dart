import 'package:flutter/material.dart';

import 'package:coordimate/components/colors.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  final List<String> _notes = [];

  _showAlertDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String newNoteTitle = ''; // Variable to store the entered title
        String newNoteDescription =
            ''; // Variable to store the entered description

        return AlertDialog(
          title: const Text(
            'Create Group',
            style:
                TextStyle(color: Colors.white), // Change title color to white
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  onChanged: (val) {
                    newNoteTitle =
                        val; // Update the newNoteTitle variable with the entered title
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10),
                    labelText: 'Title', // Label text for the title field
                    border: const OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white)), // Use white outline
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white)), // Use white outline
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                            color:
                                darkBlue)), // Change focused border color to hex value 293241
                    labelStyle: const TextStyle(
                        color: Colors.white), // Change label color to white
                    counterText:
                        '${newNoteTitle.length}/20', // Add character counter
                    counterStyle: const TextStyle(
                        color:
                            Colors.white), // Change counter text color to white
                  ),
                  maxLength: 20, // Set maximum length for the title
                  style: const TextStyle(
                      color: Colors.white), // Change input text color to white
                ),
                const SizedBox(
                    height:
                        10), // Add some space between title and description fields
                TextFormField(
                  onChanged: (val) {
                    newNoteDescription =
                        val; // Update the newNoteDescription variable with the entered description
                  },
                  maxLines:
                      3, // Increase the number of lines for the description field
                  maxLength: 300, // Set maximum length for the description
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10),
                    labelText:
                        'Description', // Label text for the description field
                    border: const OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white)), // Use white outline
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white)), // Use white outline
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                            color:
                                darkBlue)), // Change focused border color to hex value 293241
                    labelStyle: const TextStyle(
                        color: Colors.white), // Change label color to white
                    counterText:
                        '${newNoteDescription.length}/300', // Add character counter
                    counterStyle: const TextStyle(
                        color:
                            Colors.white), // Change counter text color to white
                  ),
                  style: const TextStyle(
                      color: Colors.white), // Change input text color to white
                ),
              ],
            ),
          ),
          backgroundColor:
              mediumBlue, // Set background color to hex value 3D5A80
          actions: [
            SizedBox(
              width: double.infinity, // Set width to match screen width
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end, // Align to the right
                children: [
                  OutlinedButton(
                    onPressed: () {
                      if (newNoteTitle.isNotEmpty &&
                          newNoteTitle.length <= 20) {
                        setState(() {
                          _notes.add(
                              '$newNoteTitle\n$newNoteDescription'); // Add the new note to the list with title and description
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      'Create Group',
                      style: TextStyle(
                          color: Colors
                              .white), // Change button text color to white
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  _resetNotes() {
    setState(() {
      _notes.clear(); // Clear the list to reset notes
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(kToolbarHeight + 20), // Keep the same height
        child: Container(
          padding: const EdgeInsets.only(
              top: 20), // Indent the app bar from the top by 20 pixels
          child: AppBar(
            backgroundColor: Colors.white, // Set background color to white
            title: Stack(
              children: [
                const Center(
                  child: Text(
                    'GROUPS',
                    style: TextStyle(
                      color: darkBlue, // Hex color value 293241
                      fontWeight: FontWeight.w900,
                      fontSize: 24, // Adjust font size as needed
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  top: 0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton(
                        onPressed: _showAlertDialog,
                        tooltip: 'Add Group',
                        backgroundColor:
                            darkBlue, // Set background color to hex value 3D5A80
                        elevation: 0, // Remove shadow
                        child: Image.asset(
                          'lib/images/create.png', // Path to custom icon
                        ),
                      ),
                      const SizedBox(width: 8),
                      FloatingActionButton(
                        onPressed: _resetNotes,
                        tooltip: 'Reset Groups',
                        backgroundColor:
                            darkBlue, // Set background color to hex value 3D5A80
                        elevation: 0, // Remove shadow
                        child: const Icon(
                          Icons.replay,
                          color: Colors.white, // Set icon color to white
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            centerTitle: true, // Centers the title within the app bar
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: _notes.length,
        itemBuilder: (context, index) {
          // Splitting the note into title and description
          List<String> noteParts = _notes[index].split('\n');
          String title = noteParts[0];
          String description = noteParts.length > 1
              ? noteParts[1]
              : ''; // Ensure description exists, handle if not

          return Container(
            decoration: BoxDecoration(
              color: darkBlue, // Set background color of the card to grey
              borderRadius: BorderRadius.circular(
                  10), // Add border radius to make it look like a card
            ),
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Container(
                  width: 70, // Set the width of the circle
                  height: 70, // Set the height of the circle
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle, // Make it a circle
                    color: Colors.white, // Set color to white
                  ),
                ),
                const SizedBox(
                    width: 10), // Add some space between the circle and text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 30, // Font size for title
                          color: Colors.white,
                          fontWeight: FontWeight.bold, // Make the title bold
                        ),
                      ),
                      const SizedBox(
                          height:
                              5), // Add some vertical space between title and description
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 16, // Font size for description
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
