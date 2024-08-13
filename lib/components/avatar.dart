import 'dart:async';

import 'package:flutter/material.dart';

// import 'package:image_field/image_field.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:coordimate/components/colors.dart';
import 'package:coordimate/keys.dart';

class Avatar extends StatelessWidget {
  Avatar(
      {super.key,
      required this.size,
      this.userId = '',
      this.groupId = '',
      this.clickable = false});

  final bool clickable;
  final double size;
  final String userId;
  final String groupId;
  late final id = (groupId == '') ? userId : groupId;
  late final url = (groupId == '')
      ? "$apiUrl/users/$id/avatar"
      : "$apiUrl/groups/$id/avatar";

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          if (!clickable) return;
          // TODO: upload image field
        },
        child: SizedBox(
            width: size,
            height: size,
            child: CircleAvatar(
              backgroundColor: white,
              child: Image.network(url),
            )));
  }
}

