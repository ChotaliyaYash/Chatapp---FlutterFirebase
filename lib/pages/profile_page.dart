import 'package:chatappfirebase/helper/helper_function.dart';
import 'package:chatappfirebase/pages/auth/login_page.dart';
import 'package:chatappfirebase/pages/home_page.dart';
import 'package:chatappfirebase/services/auth_services.dart';
import 'package:chatappfirebase/widgets/widgets.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ProfilePage extends StatefulWidget {
  String userName;
  String userEmail;
  ProfilePage({super.key, required this.userName, required this.userEmail});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Authentication services
  AuthServices authServices = AuthServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Appbar
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        title: const Text(
          "Profile",
          style: TextStyle(
              fontSize: 27, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),

      // body
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 170),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Icon(
              Icons.account_circle,
              size: 200,
              color: Colors.grey,
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Full Name",
                  style: TextStyle(fontSize: 17),
                ),
                Text(
                  widget.userName,
                  style: const TextStyle(fontSize: 17),
                )
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Email",
                  style: TextStyle(fontSize: 17),
                ),
                Text(
                  widget.userEmail,
                  style: const TextStyle(fontSize: 17),
                )
              ],
            )
          ],
        ),
      ),

      // Drawer
      drawer: Drawer(
        child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 50),
            children: <Widget>[
              const Icon(
                Icons.account_circle,
                size: 150,
                color: Colors.grey,
              ),
              const SizedBox(
                height: 15,
              ),

              // Username
              Text(
                widget.userName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black),
              ),

              const SizedBox(
                height: 50,
              ),
              const Divider(
                height: 2,
              ),

              ListTile(
                onTap: () {
                  nextScreenReplace(context, const HomeScreen());
                },
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                leading: const Icon(Icons.group),
                title: const Text(
                  "Groups",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ListTile(
                onTap: () {},
                selectedColor: Theme.of(context).primaryColor,
                selected: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                leading: const Icon(Icons.account_circle),
                title: const Text(
                  "Profile",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ListTile(
                onTap: () async {
                  _logoutDialog(context);
                },
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                leading: const Icon(Icons.logout),
                title: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.black),
                ),
              )
            ]),
      ),
    );
  }

// Logout Dialog
  Future<dynamic> _logoutDialog(BuildContext context) {
    return showDialog(
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
                  onPressed: signOut,
                  child: Text("Logout",
                      style: TextStyle(color: Theme.of(context).primaryColor)))
            ],
          );
        });
  }

// Logout
  signOut() async {
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
