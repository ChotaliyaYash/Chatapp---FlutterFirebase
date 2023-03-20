import 'package:chatappfirebase/helper/helper_function.dart';
import 'package:chatappfirebase/pages/auth/signin_page.dart';
import 'package:chatappfirebase/pages/home_page.dart';
import 'package:chatappfirebase/services/auth_services.dart';
import 'package:chatappfirebase/services/database_service.dart';
import 'package:chatappfirebase/shared/constants.dart';
import 'package:chatappfirebase/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginPage> {
  // Form key
  final _formKey = GlobalKey<FormState>();

  // Form controller
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  AuthServices authServices = AuthServices();

  // Loading
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor),
            )
          : SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 45),
                child: Form(
                    key: _formKey,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "Groupie",
                            style: TextStyle(
                                fontSize: 40, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            "Login now to check what they are talking!",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w400),
                          ),

                          // Image from assets
                          Image.asset(
                            'assets/images/login.png',
                            height: 300,
                            width: 300,
                          ),

                          // Email Entry
                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: textInputDecoration.copyWith(
                                labelText: "Email",
                                prefixIcon: Icon(
                                  Icons.email,
                                  color: Constants.primaryColor,
                                )),
                            validator: (value) {
                              // To check that the email contain this or not
                              return RegExp(
                                          r"^[a-zA-Z0-9.a-zA-z0-9.!#$%'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                      .hasMatch(value!)
                                  ? null
                                  : "Please enter a valid email";
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),

                          // Password Entry
                          TextFormField(
                            obscureText: true,
                            controller: passwordController,
                            keyboardType: TextInputType.text,
                            decoration: textInputDecoration.copyWith(
                                labelText: "Password",
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color: Constants.primaryColor,
                                )),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Please enter a password";
                              } else if (value.length < 6) {
                                return "Password must me atleast 6 characters";
                              } else {
                                return null;
                              }
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),

                          // Button
                          SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                  onPressed: login,
                                  child: const Text(
                                    "Login",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ))),

                          // Dont have an account
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account?",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16),
                              ),
                              TextButton(
                                  onPressed: () {
                                    nextScreen(context, const SignInPage());
                                  },
                                  child: Text(
                                    "Register here",
                                    style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        color: Constants.primaryColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal),
                                  ))
                            ],
                          )
                        ])),
              ),
            ),
    );
  }

  login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authServices
          .loginUserWithEmailandPassword(
              emailController.text, passwordController.text)
          .then((value) async {
        if (value == true) {
          // Fatching user name
          QuerySnapshot snapshot =
              await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                  .getUserData(emailController.text);

          // Setting a Shared Veriable
          await HelperFunction.saveUserLoggedInKey(true);
          await HelperFunction.saveUserEmail(emailController.text);
          await HelperFunction.saveUserName(snapshot.docs[0]["fullname"]);
          // ignore: use_build_context_synchronously
          nextScreen(context, const HomeScreen());
          setState(() {
            _isLoading = false;
          });
        } else {
          showSnackBar(context, Colors.red, value);
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }
}
