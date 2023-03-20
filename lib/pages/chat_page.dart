import 'package:chatappfirebase/pages/group_info.dart';
import 'package:chatappfirebase/pages/message_tile.dart';
import 'package:chatappfirebase/services/database_service.dart';
import 'package:chatappfirebase/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;

  const ChatPage(
      {super.key,
      required this.groupId,
      required this.groupName,
      required this.userName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // Controller
  final messageController = TextEditingController();

  // Chat steam
  Stream<QuerySnapshot>? chats;

  // admin Name
  String admin = "";

// Get chat and admin
  getChatandAdmin() async {
    // Get chat
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getChat(widget.groupId)
        .then((value) {
      setState(() {
        chats = value;
      });
    });
    // Get admin name
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGroupAdmin(widget.groupId)
        .then((value) {
      setState(() {
        admin = value;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getChatandAdmin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _appBarChat(context),
        body: Stack(
          children: <Widget>[
            // chat messages
            chatMessages(),
            Container(
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                color: Colors.grey[700],
                child: Row(
                  children: [
                    Expanded(
                        child: TextFormField(
                      controller: messageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                          hintText: "Send a message",
                          hintStyle:
                              TextStyle(color: Colors.white, fontSize: 16),
                          border: InputBorder.none),
                    )),
                    const SizedBox(
                      width: 12,
                    ),
                    GestureDetector(
                      onTap: sendMessage,
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Center(
                          child: Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ));
  }

// chatmessages
  chatMessages() {
    return StreamBuilder(
        stream: chats,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  return MessageTile(
                      message: snapshot.data.docs[index]['message'],
                      sender: snapshot.data.docs[index]['sender'],
                      sendByMe: snapshot.data.docs[index]['sender'] ==
                          widget.userName);
                });
          } else {
            return Container();
          }
        });
  }

// sendMessage
  sendMessage() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        "sender": widget.userName,
        "time": DateTime.now().millisecondsSinceEpoch
      };
      DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
      });
    }
  }

// appbar
  AppBar _appBarChat(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).primaryColor,
      centerTitle: true,
      title: Text(
        widget.groupName,
        style: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 27, color: Colors.white),
      ),
      actions: [
        IconButton(
            onPressed: () {
              nextScreen(
                  context,
                  GroupInfo(
                      groupId: widget.groupId,
                      groupName: widget.groupName,
                      adminName: admin));
            },
            icon: const Icon(Icons.info))
      ],
    );
  }
}
