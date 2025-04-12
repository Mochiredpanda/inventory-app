import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Components/my_profile_popup_menu_button.dart';
import '../FirebaseSettings/firestore_provider.dart';

/// MyProfile Page
///
/// A StatefulWidget that displays the profile info about the current user
/// The page includes an Icon, user first and last names, and user email
/// It uses Firestore to fetch and display user data based on userId
class MyProfilePage extends StatefulWidget {
  /// Constructs MyProfilePage
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  final firestoreProvider = FirestoreProvider();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          automaticallyImplyLeading: false,
          title: const Text(
            "MY PROFILE",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
            ),
            semanticsLabel: 'My Profile',
          ),
          actions: const <Widget>[MyProfilePopupMenuButton()],
        ),
        body: StreamBuilder<DocumentSnapshot>(
            // Using StreamBuilder to fetch data
            stream: firestoreProvider.fetchUserDataStream(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
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
                DocumentSnapshot userData = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: Column(
                    children: [
                      const Center(
                        child: CircleAvatar(
                          backgroundColor: Colors.black,
                          radius: 125,
                          child: CircleAvatar(
                            radius: 120,
                            backgroundImage:
                                ExactAssetImage('images/picture_logo.png'),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Center(
                        child: Text(
                          userData['FirstName'],
                          style: const TextStyle(
                              fontSize: 50, fontWeight: FontWeight.bold),
                          semanticsLabel: userData['FirstName'],
                        ),
                      ),
                      Center(
                        child: Text(
                          userData['LastName'],
                          style: const TextStyle(
                              fontSize: 50, fontWeight: FontWeight.bold),
                          semanticsLabel: userData['LastName'],
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Center(
                        child: Text(
                          userData['Email'],
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          semanticsLabel: userData['Email'],
                        ),
                      )
                    ],
                  ),
                );
              }
            }));
  }
}
