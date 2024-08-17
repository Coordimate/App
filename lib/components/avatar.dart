import 'dart:developer';
import 'dart:io';

import 'package:coordimate/app_state.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:image_picker/image_picker.dart';
import 'package:coordimate/components/colors.dart';
import 'package:coordimate/keys.dart';

class _PickPictureButton extends StatelessWidget {
  final String text;
  final Function()? onTap;

  const _PickPictureButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          color: white,
          border: Border.all(color: white, width: 3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
                // fontWeight: FontWeight.bold,
                fontSize: 24),
          ),
        ),
      ),
    );
  }
}

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

  uploadAvatar(XFile? image) async {
    if (image == null) {
      log("No image picked");
      return;
    }
    var request =
        http.MultipartRequest('POST', Uri.parse("$apiUrl/upload_avatar/$id"));
    request.files.add(http.MultipartFile.fromBytes(
        'file', File(image.path).readAsBytesSync(),
        filename: image.path));
    var streamedResponse = await request.send();
    await http.Response.fromStream(streamedResponse);
  }

  @override
  Widget build(BuildContext context) {
    Widget image;
    if (AppState.testMode) {
      image = Container(
          width: size,
          height: size,
          child: Image.asset('lib/images/person.png'));
    } else {
      image = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: white,
          image: DecorationImage(
            fit: BoxFit.fill,
            image: NetworkImage(url),
          ),
        ),
      );
    }
    return GestureDetector(
        onTap: () async {
          if (!clickable) return;
          showModalBottomSheet<String>(
              context: context,
              builder: (BuildContext context) {
                return Container(
                    height: 200,
                    color: white,
                    child: Center(
                      child: Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            _PickPictureButton(
                                text: 'Take Picture',
                                onTap: () async {
                                  Navigator.pop(context);
                                  final ImagePicker picker = ImagePicker();
                                  final XFile? image = await picker.pickImage(
                                      source: ImageSource.camera);
                                  uploadAvatar(image);
                                }),
                            _PickPictureButton(
                                text: 'Choose Picture',
                                onTap: () async {
                                  Navigator.pop(context);
                                  final ImagePicker picker = ImagePicker();
                                  final XFile? image = await picker.pickImage(
                                      source: ImageSource.gallery);
                                  uploadAvatar(image);
                                }),
                          ],
                        ),
                      ),
                    ));
              });
        },
        child: image);
  }
}
