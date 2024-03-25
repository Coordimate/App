import 'package:flutter/material.dart';
import 'package:coordimate/components/colors.dart';
import 'package:coordimate/components/main_navigation.dart';
import 'package:coordimate/components/create_groups_button.dart'; // Import the CreateGroupsButton

class GroupsPage extends StatefulWidget {
  @override
  _GroupsPageState createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  bool _isAddButtonPressed = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              top: screenHeight * 0.07,
              bottom: 20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // "Groups" header
                Text(
                  "Groups",
                  style: TextStyle(
                    color: darkBlue,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 20), // Increased spacing between text and +
                // "+" button
                InkWell(
                  onTapDown: (_) {
                    setState(() {
                      _isAddButtonPressed = true;
                    });
                  },
                  onTapUp: (_) {
                    setState(() {
                      _isAddButtonPressed = false;
                    });
                  },
                  onTapCancel: () {
                    setState(() {
                      _isAddButtonPressed = false;
                    });
                  },
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          CreateGroupsButton(), // Navigate to CreateGroupsButton page
                    ));
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _isAddButtonPressed ? mediumBlue : darkBlue,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          NavBar(key: UniqueKey()), // Bottom icons widget
          SizedBox(height: screenHeight * 0.01),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: GroupsPage(),
    theme: ThemeData(
      primaryColor: darkBlue,
    ),
  ));
}
