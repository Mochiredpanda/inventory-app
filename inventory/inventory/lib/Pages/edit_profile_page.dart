import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../FirebaseSettings/firestore_provider.dart';

/// Edit Profile Page
///
/// A StatefulWidget allows users to change their profile details and updates
/// with the data stored on firebase database
/// The changed names also updated with the house list filter displays
class EditProfilePage extends StatefulWidget {
  /// constructs EditProfilePage
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Initialize input field controllers
  final firestoreProvider = FirestoreProvider();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final db = FirebaseFirestore.instance;

  /// Get User Id
  ///
  /// Helper method to get Current User identifier from firebase
  String? _getCurUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  /// Popup window of Notice
  ///
  /// Helper method to trigger a popup window to show Item added successfully
  void _showAddedWindow() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Success',
            semanticsLabel: 'Success',
          ),
          content: const Text(
            'Profile successfully updated.',
            semanticsLabel: 'Profile successfully updated',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'OK',
                semanticsLabel: 'Ok',
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text(
            "EDIT PROFILE",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
            ),
            semanticsLabel: 'Edit profile',
          ),
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          ),
        ),
        body: FutureBuilder(
            // Fetch User data
            future: firestoreProvider.fetchUserData(),
            builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    "Error! Something went wrong",
                    semanticsLabel: 'Error! Something went wrong',
                  ),
                );
              } else {
                Map<String, dynamic> userData = snapshot.data!;
                return SingleChildScrollView(
                  child: Form(
                      child: Column(children: [
                    _personalInfoInputBox("First Name", userData['FirstName'],
                        _firstNameController),
                    _personalInfoInputBox(
                        "Last Name", userData['LastName'], _lastNameController),
                    Container(
                        padding: const EdgeInsets.only(
                            top: 40.0, left: 35.0, right: 35.0, bottom: 20.0),
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.black,
                            textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1),
                            fixedSize: const Size(200, 40),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7)),
                          ),
                          onPressed: () {
                            // uses original values if user does not put in new value
                            String dataFirstName =
                                (_firstNameController.text == "")
                                    ? userData['FirstName']
                                    : _firstNameController.text;
                            String dataLastName =
                                (_lastNameController.text == "")
                                    ? userData['LastName']
                                    : _lastNameController.text;
                            final userDoc =
                                db.collection("Users").doc(_getCurUserId());
                            userDoc.update({
                              "FirstName": dataFirstName,
                              "LastName": dataLastName,
                            });
                            _showAddedWindow();
                            Navigator.of(context).pop();
                          },
                          child: const Text('Submit Update'),
                        )),
                  ])),
                );
              }
            }));
  }

  /// Creates an input box for personal info change page
  ///
  /// [text] - the label and prompt text for the input box
  /// [placeholder] - optional param to set the top padding of input box
  /// [controller] - the input field text controller
  ///
  /// Returns a widget containing a label and a TextFormField for info change input
  Widget _personalInfoInputBox(String text, String placeholder, controller,
      {bool hiddenText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 35, top: 15),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.grey,
              height: 1.5,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
            semanticsLabel: text,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 35, right: 35),
          child: SizedBox(
            height: 35,
            child: TextFormField(
              controller: controller,
              obscureText: hiddenText,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.only(left: 10, right: 10),
                hintText: placeholder,
                hintStyle: const TextStyle(fontSize: 13),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
