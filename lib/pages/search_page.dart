import 'package:chatappfirebase/helper/helper_function.dart';
import 'package:chatappfirebase/pages/chat_page.dart';
import 'package:chatappfirebase/services/database_service.dart';
import 'package:chatappfirebase/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // controller
  final searchController = TextEditingController();

  // for search data
  QuerySnapshot? searchSnapshot;
  bool userHasSearched = false;

  // For loading data
  bool _isLoading = false;

  // For userName
  String userName = "";

  // user is joined or not
  bool _isJoined = false;

  // user id
  User? user;

  @override
  void initState() {
    super.initState();
    getUserIdandName();
  }

  getName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  getUserIdandName() async {
    await HelperFunction.getUserName().then((value) {
      setState(() {
        userName = value!;
      });
    });
    user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
          centerTitle: true,
          title: const Text(
            "Search",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w500, fontSize: 27),
          ),
        ),
        // ignore: prefer_const_constructors
        body: Column(
          children: [
            // Container for search Button.
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              color: Theme.of(context).primaryColor,
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    controller: searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        hintStyle: TextStyle(color: Colors.white, fontSize: 16),
                        hintText: "Search Groups"),
                  )),
                  IconButton(
                      onPressed: () {
                        iniciateSearchMethod();
                      },
                      icon: const Icon(
                        Icons.search,
                        color: Colors.white,
                      ))
                ],
              ),
            ),

            // Dispaly search object
            _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                        color: Theme.of(context).primaryColor),
                  )
                : getSearchData()
          ],
        ));
  }

  iniciateSearchMethod() async {
    if (searchController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      await DatabaseService(uid: user!.uid)
          .getSearchData(searchController.text)
          .then((value) {
        setState(() {
          searchSnapshot = value;
          _isLoading = false;
          userHasSearched = true;
        });
      });
    }
  }

  getSearchData() {
    return userHasSearched
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchSnapshot!.docs.length,
            itemBuilder: (context, index) {
              return searchGroupTile(
                userName,
                searchSnapshot!.docs[index]['groupId'],
                searchSnapshot!.docs[index]['groupName'],
                searchSnapshot!.docs[index]['admin'],
              );
            })
        : Container();
  }

  searchGroupTile(
      String userName, String groupId, String groupName, String admin) {
    // Function to check that user is exist or not
    joinedornot(userName, groupId, groupName, admin);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(
          groupName[0],
          style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
        ),
      ),
      title: Text(
        groupName,
        style: const TextStyle(
            color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
      ),
      subtitle: Text("Admin: ${getName(admin)}"),
      trailing: InkWell(
          onTap: () async {
            await DatabaseService(uid: user!.uid)
                .toggleUserInGroup(groupId, groupName, userName);
            if (_isJoined) {
              setState(() {
                _isJoined = !_isJoined;
              });
              // ignore: use_build_context_synchronously
              showSnackBar(
                  context, Colors.green, "Successfully joined the group");
              Future.delayed(const Duration(seconds: 2), () {
                nextScreen(
                    context,
                    ChatPage(
                        groupId: groupId,
                        groupName: groupName,
                        userName: userName));
              });
            } else {
              setState(() {
                _isJoined = !_isJoined;
              });
              // ignore: use_build_context_synchronously
              showSnackBar(context, Colors.red, "Left the group $groupName");
            }
          },
          child: _isJoined
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black,
                      border: Border.all(color: Colors.white, width: 1)),
                  child: const Text(
                    "Joined",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context).primaryColor,
                      border: Border.all(color: Colors.white, width: 1)),
                  child: const Text(
                    "Join Now",
                    style: TextStyle(color: Colors.white),
                  ),
                )),
    );
  }

  joinedornot(
      String userName, String groupId, String groupName, String admin) async {
    await DatabaseService(uid: user!.uid)
        .isUserJoined(groupId, groupName, userName)
        .then((value) {
      setState(() {
        _isJoined = value;
      });
    });
  }
}
