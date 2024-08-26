import 'dart:convert';

import 'package:coordimate/components/appbar.dart';
import 'package:coordimate/components/avatar.dart';
import 'package:coordimate/components/colors.dart';
import 'package:coordimate/models/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:coordimate/keys.dart';

class ChatMessage extends StatelessWidget {
  final bool isFromUser;
  final bool isFirst;
  final String username;
  final String text;
  final Avatar avatar;

  const ChatMessage({
    super.key,
    required this.text,
    required this.username,
    required this.avatar,
    this.isFirst = false,
    this.isFromUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        (!isFromUser && isFirst
            ? Padding(padding: const EdgeInsets.all(5), child: avatar)
            : const SizedBox(width: 40, height: 30)),
        Column(
            crossAxisAlignment:
                isFromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              ((isFirst && !isFromUser) ? Text(username) : Container()),
              Container(
                  decoration: BoxDecoration(
                    color: !isFromUser ? darkBlue : lightBlue,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(10),
                      topRight: const Radius.circular(10),
                      bottomLeft: Radius.circular(isFromUser ? 10 : 0),
                      bottomRight: Radius.circular(isFromUser ? 0 : 10),
                    ),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Text(text,
                        style: TextStyle(
                            color: !isFromUser ? Colors.white : Colors.black)),
                  ))
            ]),
      ],
    );
  }
}

class GroupChatPage extends StatefulWidget {
  const GroupChatPage({
    super.key,
    required this.title,
    required this.userId,
    required this.groupId,
    required this.memberAvatars,
    required this.memberUsernames,
    required this.chatMessages,
  });

  final String title;
  final String userId;
  final String groupId;
  final Map<String, Avatar> memberAvatars;
  final Map<String, String> memberUsernames;
  final List<ChatMessage> chatMessages;

  @override
  State<GroupChatPage> createState() => GroupChatPageState();
}

class GroupChatPageState extends State<GroupChatPage> {
  String lastSenderId = '';
  String lastMessage = '';

  final TextEditingController _controller = TextEditingController();
  late final channel = WebSocketChannel.connect(
    Uri.parse('$wsUrl/${widget.groupId}/${widget.userId}'),
  );

  List<ChatMessage> oldMessages = [];
  List<ChatMessage> messages = [];

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    oldMessages = widget.chatMessages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: const CustomAppBar(needButton: false, title: "Group Chat"),
        body: Column(children: [
          Expanded(
              child: GestureDetector(
                onPanDown: (_) {
                  FocusScope.of(context).unfocus();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: StreamBuilder(
                              stream: channel.stream,
                              builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var msg = snapshot.data;
                    if (msg != '{}' && msg != lastMessage) {
                      var chatMessage = ChatMessageModel.fromJson(
                          json.decode(msg.toString()));
                      messages.add(ChatMessage(
                          avatar: widget.memberAvatars[chatMessage.userId]!,
                          username: widget.memberUsernames[chatMessage.userId]!,
                          text: chatMessage.text,
                          isFromUser: widget.userId == chatMessage.userId,
                          isFirst: lastSenderId != chatMessage.userId));
                      lastSenderId = chatMessage.userId;
                      lastMessage = msg;
                    }

                    return ListView.builder(
                      itemCount: oldMessages.length + messages.length,
                      controller: _scrollController,
                      itemBuilder: (context, index) {
                        Future.delayed(
                            const Duration(milliseconds: 400),
                            () => _scrollController.animateTo(
                                _scrollController.position.maxScrollExtent,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.linear));
                        if (index < oldMessages.length) {
                          return oldMessages.toList()[index];
                        } else {
                          return messages.toList()[index - oldMessages.length];
                        }
                      },
                    );
                  } else {
                    return const Text('');
                  }
                              },
                            ),
                ),
              )),
          SafeArea(
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.8,
                            child: TextField(
                              autofocus: true,
                              controller: _controller,
                            )),
                        IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: _sendMessage)
                      ]))),
        ]));
  }

  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      channel.sink.add(
          json.encode({'user_id': widget.userId, 'text': _controller.text}));
      _controller.clear();
    }
  }

  @override
  void dispose() {
    channel.sink.close();
    _controller.dispose();
    super.dispose();
  }
}
