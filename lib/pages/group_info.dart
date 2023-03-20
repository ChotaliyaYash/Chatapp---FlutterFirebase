import 'package:chatappfirebase/helper/helper_function.dart';
import 'package:chatappfirebase/pages/home_page.dart';
import 'package:chatappfirebase/services/database_service.dart';
import 'package:chatappfirebase/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupInfo extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String adminName;
  const GroupInfo(
      {super.key,
      required this.groupId,
      required this.groupName,
      required this.adminName});

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  Stream? members;

  toName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  toId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  // Initial
  @override
  void initState() {
    super.initState();
    getGroupMembers();
  }

  // Get group members
  getGroupMembers() async {
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGroupMembers(widget.groupId)
        .then((value) {
      setState(() {
        members = value;
      });
    });
  }

  // username
  String userName = "";

  // userName
  getUserName() async {
    await HelperFunction.getUserName().then((value) {
      setState(() {
        userName = value!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        title: const Text(
          "Group Info",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 27),
        ),
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Exit"),
                        content:
                            const Text("Are you sure, you want to exit group?"),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("Cancel",
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor))),
                          TextButton(
                              onPressed: () {
                                DatabaseService(
                                        uid: FirebaseAuth
                                            .instance.currentUser!.uid)
                                    .toggleUserInGroup(widget.groupId,
                                        widget.groupName, userName)
                                    .whenComplete(() {
                                  nextScreenReplace(
                                      context, const HomeScreen());
                                });
                              },
                              child: Text("Exit",
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor)))
                        ],
                      );
                    });
              },
              icon: const Icon(Icons.exit_to_app))
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(children: [
          // Admin Details Container
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Theme.of(context).primaryColor.withOpacity(0.2),
            ),
            child: ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  widget.groupName[0].toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 20),
                ),
              ),
              title: Text(
                "Group: ${widget.groupName}",
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                "Admin: ${toName(widget.adminName)}",
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),

          // All members details
          memberlist(),
        ]),
      ),
    );
  }

  memberlist() {
    return StreamBuilder(
        stream: members,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data['members'] != null) {
              if (snapshot.data['members'].length != 0) {
                return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data['members'].length,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.all(15),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Text(
                              toName(snapshot.data['members'][index])[0],
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20),
                            ),
                          ),
                          title: Text(
                            toName(snapshot.data['members'][index]),
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            toId(snapshot.data['members'][index]),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      );
                    });
              } else {
                return const Center(
                  child: Text("No Members in the group"),
                );
              }
            } else {
              return const Center(
                child: Text("No Members in the group"),
              );
            }
          } else {
            return Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor),
            );
          }
        });
  }
}
