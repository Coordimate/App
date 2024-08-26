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
          child: Column(
            children: [
              Icon(
                text == 'Take Photo' ? Icons.camera_alt : Icons.image,
                color: darkBlue,
                // size: 40,
              ),
              Text(
                text,
                style: const TextStyle()
                    // fontWeight: FontWeight.bold,
                    // fontSize: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Avatar extends StatefulWidget {
  final bool clickable;
  final double size;
  final String userId;
  final String groupId;

  const Avatar({
    super.key,
    required this.size,
    this.userId = '',
    this.groupId = '',
    this.clickable = false
  });

  @override
  State<Avatar> createState() => _AvatarState();
}

class _AvatarState extends State<Avatar>{
  late String id;
  late String url;
  int imageRefreshKey = DateTime.now().millisecondsSinceEpoch; // Cache buster

  @override
  void initState() {
    super.initState();
    id = (widget.groupId == '') ? widget.userId : widget.groupId;
    url = (widget.groupId == '')
        ? "$apiUrl/users/$id/avatar"
        : "$apiUrl/groups/$id/avatar";
  }

  Future<void> uploadAvatar(XFile? image) async {
    if (image == null) {
      log("No image picked");
      return;
    }

    var imageBytes = await File(image.path).readAsBytes();
    var croppedImage = await AppState.authController.cropToSquare(imageBytes);

    var request =
        http.MultipartRequest('POST', Uri.parse("$apiUrl/upload_avatar/$id"));
    request.files.add(http.MultipartFile.fromBytes(
        'file', croppedImage,
        filename: image.path));
    var streamedResponse = await request.send();
    await http.Response.fromStream(streamedResponse);
    setState(() {
      imageRefreshKey = DateTime.now().millisecondsSinceEpoch;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget image;
    if (AppState.testMode) {
      image = SizedBox(
          width: widget.size,
          height: widget.size,
          child: Image.asset('lib/images/person.png'));
    } else {
      image = Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: white,
          image: DecorationImage(
            fit: BoxFit.fill,
            image: NetworkImage('$url?refresh=$imageRefreshKey'),
          ),
        ),
      );
    }
    return GestureDetector(
        onTap: () async {
          if (!widget.clickable) return;
          showModalBottomSheet<String>(
              context: context,
              builder: (BuildContext context) {
               return IntrinsicHeight(
                 child: Container(
                    color: white,
                    // height: 200,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Flexible(
                            child: _PickPictureButton(
                                text: 'Take Photo',
                                onTap: () async {
                                  Navigator.pop(context);
                                  final ImagePicker picker = ImagePicker();
                                  final XFile? image = await picker.pickImage(
                                      source: ImageSource.camera);
                                  await uploadAvatar(image);
                                }),
                          ),
                          Flexible(
                            child: _PickPictureButton(
                                text: 'Choose Picture',
                                onTap: () async {
                                  Navigator.pop(context);
                                  final ImagePicker picker = ImagePicker();
                                  final XFile? image = await picker.pickImage(
                                      source: ImageSource.gallery);
                                  await uploadAvatar(image);
                                }),
                          ),
                        ],
                      ),
                    ),
                  ),
               );
              });
        },
        child: image);
  }
}
