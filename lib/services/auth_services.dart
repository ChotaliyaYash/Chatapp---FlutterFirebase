// ignore_for_file: unused_import

import 'package:chatappfirebase/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthServices {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  // Login

  Future loginUserWithEmailandPassword(String email, String password) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Sign in

  Future registerUserWithUserandPassword(
      String fullname, String email, String password) async {
    try {
      // Saving user details in user
      User user = (await firebaseAuth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user!;

      await DatabaseService(uid: user.uid).setUserData(fullname, email);
      return true;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Signout

  Future signOutUser() async {
    try {
      await firebaseAuth.signOut();
      return true;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }
}
