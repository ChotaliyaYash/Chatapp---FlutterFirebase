import 'package:shared_preferences/shared_preferences.dart';

class HelperFunction {
  // variables for user details
  static String userLoggedInKey = "LOGGEDINKEY";
  static String userNameKey = "USERNAMEKEY";
  static String userEmailKey = "USEREMAILKEY";

  // setting the loggedin status in Shared_function
  static Future<bool?> saveUserLoggedInKey(bool isUserLoggedIn) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return await sp.setBool(userLoggedInKey, isUserLoggedIn);
  }

  // setting the user name in Shared function
  static Future<bool?> saveUserName(String userName) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return await sp.setString(userNameKey, userName);
  }

  // setting the user email in shared function
  static Future<bool?> saveUserEmail(String userEmail) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return await sp.setString(userEmailKey, userEmail);
  }

  // getting the data from Shared_function
  static Future<bool?> getUserLoggedInStatus() async {
    // Used an sharePreference to get the user is loggedin or not from device storage
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getBool(userLoggedInKey);
  }

  // getting user anme from Share function
  static Future<String?> getUserName() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString(userNameKey);
  }

  // getting user anme from Share function
  static Future<String?> getUserEmail() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString(userEmailKey);
  }
}
