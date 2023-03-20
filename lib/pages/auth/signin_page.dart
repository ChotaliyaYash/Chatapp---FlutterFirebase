import 'package:chatappfirebase/helper/helper_function.dart';
import 'package:chatappfirebase/pages/auth/login_page.dart';
import 'package:chatappfirebase/pages/home_page.dart';
import 'package:chatappfirebase/services/auth_services.dart';
import 'package:chatappfirebase/shared/constants.dart';
import 'package:chatappfirebase/widgets/widgets.dart';
import 'package:flutter/material.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  // Formkey
  final _formKey = GlobalKey<FormState>();

  // Text controller
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  // Auth services
  AuthServices authServices = AuthServices();

  // for loading
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
                            "Create your account now to chat and explore",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w400),
                          ),
                          Image.asset(
                            'assets/images/register.png',
                            height: 300,
                            width: 300,
                          ),

                          // name Entry
                          TextFormField(
                            controller: nameController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: textInputDecoration.copyWith(
                                labelText: "Full name",
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: Constants.primaryColor,
                                )),
                            validator: (value) {
                              // To check that the email contain this or not
                              if (value!.isEmpty) {
                                return "Please enter your name";
                              } else {
                                return null;
                              }
                            },
                          ),
                          const SizedBox(
                            height: 15,
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
                            height: 15,
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
                                  onPressed: signin,
                                  child: const Text(
                                    "Register",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ))),

                          // Dont have an account
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Already have an account?",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16),
                              ),
                              TextButton(
                                  onPressed: () {
                                    nextScreen(context, const LoginPage());
                                  },
                                  child: Text(
                                    "Login now",
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

  void signin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authServices
          .registerUserWithUserandPassword(nameController.text,
              emailController.text, passwordController.text)
          .then((value) async {
        if (value == true) {
          // shave value to shared preference state
          await HelperFunction.saveUserLoggedInKey(true);
          await HelperFunction.saveUserEmail(emailController.text);
          await HelperFunction.saveUserName(nameController.text);
          // ignore: use_build_context_synchronously
          nextScreenReplace(context, const HomeScreen());
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
