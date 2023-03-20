import 'package:chatappfirebase/helper/helper_function.dart';
import 'package:chatappfirebase/pages/auth/login_page.dart';
import 'package:chatappfirebase/pages/profile_page.dart';
import 'package:chatappfirebase/pages/search_page.dart';
import 'package:chatappfirebase/services/auth_services.dart';
import 'package:chatappfirebase/services/database_service.dart';
import 'package:chatappfirebase/widgets/group_tile.dart';
import 'package:chatappfirebase/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // AuthService instance for an uid of an signed in user
  AuthServices authServices = AuthServices();

  String userName = "";
  String userEmail = "";

  Stream? groups;

  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  final groupController = TextEditingController();

// Getting user data
  getUserData() async {
    // user Name
    await HelperFunction.getUserName().then((value) {
      if (value != null) {
        setState(() {
          userName = value;
        });
      }
    });

    // User email
    await HelperFunction.getUserEmail().then((value) {
      if (value != null) {
        setState(() {
          userEmail = value;
        });
      }
    });

    // Getting a snapshot of user and save in stream
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getuserGroup()
        .then((value) {
      setState(() {
        groups = value;
      });
    });
  }

// String manupalation
  getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  getName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

// initState for getting name and email
  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _homeAppBar(context),
      body: groupList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          popUpDialog(context);
        },
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
      drawer: _homePageDrawer(context),
    );
  }

// Show group
  groupList() {
    return StreamBuilder(
        stream: groups,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data['group'] != null) {
              if (snapshot.data['group'].length != 0) {
                return ListView.builder(
                    itemCount: snapshot.data['group'].length,
                    itemBuilder: (context, index) {
                      int reverseIndex =
                          snapshot.data['group'].length - index - 1;
                      return GroupTile(
                          groupName:
                              getName(snapshot.data['group'][reverseIndex]),
                          groupId: getId(snapshot.data['group'][reverseIndex]),
                          userName: userName);
                    });
              } else {
                return noGroupWidget();
              }
            } else {
              return noGroupWidget();
            }
          } else {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            );
          }
        });
  }

// If no group is for a person
  noGroupWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                popUpDialog(context);
              },
              child: Icon(
                Icons.add_circle,
                color: Colors.grey[700],
                size: 75,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "You've not joined any groups, tap on the add icon to create a  group or also search from top search button",
              textAlign: TextAlign.center,
            )
          ]),
    );
  }

// Home page drawer
  Drawer _homePageDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 50),
        children: <Widget>[
          // Icon for an user
          const Icon(
            Icons.account_circle,
            size: 150,
            color: Colors.grey,
          ),
          const SizedBox(
            height: 15,
          ),

          // Name of an user
          Text(
            userName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 30,
          ),

          const Divider(
            height: 2,
          ),

          // Groups
          ListTile(
            leading: const Icon(Icons.group),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            title: const Text(
              "Groups",
              style: TextStyle(color: Colors.black),
            ),
            selectedColor: Theme.of(context).primaryColor,
            selected: true,
            onTap: () {},
          ),

          // Profile
          ListTile(
            leading: const Icon(Icons.account_circle),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            title: const Text(
              "Profile",
              style: TextStyle(color: Colors.black),
            ),
            onTap: () {
              nextScreen(
                  context,
                  ProfilePage(
                    userName: userName,
                    userEmail: userEmail,
                  ));
            },
          ),

          // Profile
          ListTile(
            leading: const Icon(Icons.logout),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.black),
            ),
            onTap: () async {
              _logoutDialogBox(context);
            },
          )
        ],
      ),
    );
  }

// Logout Dialog box
  Future<dynamic> _logoutDialogBox(BuildContext context) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Logout"),
            content: const Text("Are you sure, you want to logout?"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancel",
                      style: TextStyle(color: Theme.of(context).primaryColor))),
              TextButton(
                  onPressed: signout,
                  child: Text("Logout",
                      style: TextStyle(color: Theme.of(context).primaryColor)))
            ],
          );
        });
  }

// App bar
  AppBar _homeAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).primaryColor,
      centerTitle: true,
      actions: [
        IconButton(
            onPressed: () {
              nextScreen(context, const SearchPage());
            },
            icon: const Icon(Icons.search))
      ],
      title: const Text(
        "Groups",
        style: TextStyle(
            fontSize: 27, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

// For creating new group
  popUpDialog(context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Create a group"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    : Form(
                        key: _formKey,
                        child: TextFormField(
                          controller: groupController,
                          decoration: InputDecoration(
                              labelStyle: TextStyle(
                                  color: Theme.of(context).primaryColor),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor),
                                  borderRadius: BorderRadius.circular(20)),
                              errorBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(20)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor),
                                  borderRadius: BorderRadius.circular(20)),
                              labelText: "Group Name"),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please enter a group name";
                            } else {
                              return null;
                            }
                          },
                        )),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancel",
                      style: TextStyle(color: Theme.of(context).primaryColor))),
              TextButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _isLoading = true;
                      });
                      await DatabaseService(
                              uid: FirebaseAuth.instance.currentUser!.uid)
                          .createGroup(userName, groupController.text)
                          .whenComplete(() {
                        setState(() {
                          _isLoading = false;
                        });
                        Navigator.pop(context);
                        showSnackBar(context, Colors.green,
                            "Group Created Successfully");
                      });
                    }
                  },
                  child: Text(
                    "Create",
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ))
            ],
          );
        });
  }

// Signput function
  signout() async {
    await authServices.signOutUser().then((value) async {
      if (value == true) {
        await HelperFunction.saveUserLoggedInKey(false);
        await HelperFunction.saveUserEmail("");
        await HelperFunction.saveUserName("");
        // ignore: use_build_context_synchronously
        nextScreenReplace(context, const LoginPage());
      } else {
        showSnackBar(context, Colors.red, value);
      }
    });
  }
}
