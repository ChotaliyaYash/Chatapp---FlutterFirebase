import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});

// user collection
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("user");

  // group collection
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("group");

  // set user data in database;
  Future setUserData(String fullname, String email) async {
    return await userCollection.doc(uid).set({
      "fullname": fullname,
      "email": email,
      "group": [],
      "profilePic": "",
      "uid": uid
    });
  }

  Future getUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

// Get user group
  Future getuserGroup() async {
    return userCollection.doc(uid).snapshots();
  }

// Creating a group
  Future createGroup(String userName, String groupName) async {
    DocumentReference groupDocumentReference = await groupCollection.add({
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${uid}_$userName",
      "members": [],
      "groupId": "",
      "recentMessage": "",
      "recentMessageSender": "",
      "recentmessageTime": ""
    });

    // This will create a member
    await groupDocumentReference.update({
      "members": FieldValue.arrayUnion(["${uid}_$userName"]),
      "groupId": groupDocumentReference.id,
    });

    // also we nned to go to user collection and update the group
    DocumentReference userDocumentReference = userCollection.doc(uid);

    return userDocumentReference.update({
      "group":
          FieldValue.arrayUnion([("${groupDocumentReference.id}_$groupName")])
    });
  }

  // Gettign message
  Future getChat(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

// Get group admin name
  Future getGroupAdmin(String groupId) async {
    DocumentReference documentReference = groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await documentReference.get();
    return documentSnapshot['admin'];
  }

  // Get Group Members
  Future getGroupMembers(String groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }

  // Getting search data
  Future getSearchData(String searchName) async {
    return groupCollection.where("groupName", isEqualTo: searchName).get();
  }

  // Check if user is exist or not
  Future<bool> isUserJoined(
      String groupId, String groupName, String userName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentSnapshot userDocumentSnapshot = await userDocumentReference.get();

    List<dynamic> groups = userDocumentSnapshot['group'];
    if (groups.contains("${groupId}_$groupName")) {
      return true;
    } else {
      return false;
    }
  }

  // Add and delete user from group
  Future toggleUserInGroup(
      String groupId, String groupName, String userName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);

    DocumentSnapshot userDocumentSnapshot = await userDocumentReference.get();
    List<dynamic> groups = userDocumentSnapshot['group'];

    if (groups.contains("${groupId}_$groupName")) {
      await userDocumentReference.update({
        "group": FieldValue.arrayRemove(["${groupId}_$groupName"])
      });

      await groupDocumentReference.update({
        "members": FieldValue.arrayRemove(["${uid}_$userName"])
      });
    } else {
      await userDocumentReference.update({
        "group": FieldValue.arrayUnion(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayUnion(["${uid}_$userName"])
      });
    }
  }

  // Saving message to database
  Future sendMessage(
      String groupId, Map<String, dynamic> chatMessageMap) async {
    await groupCollection
        .doc(groupId)
        .collection("messages")
        .add(chatMessageMap);
    await groupCollection.doc(groupId).update({
      "recentMessage": chatMessageMap["message"],
      "recentMessageSender": chatMessageMap["sender"],
      "recentmessageTime": chatMessageMap["time"].toString(),
    });
  }
}
