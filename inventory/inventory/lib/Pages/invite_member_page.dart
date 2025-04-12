import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'dart:convert';

/// Invite Member Page
///
/// A StatefulWidget generates a QR code for users to invite others to a household
/// and append the invitee userId to the house member list
/// The QR code contains a JSON data with houseId and a timestamp for a
/// time expiration validation and then encoded
class InviteMemberPage extends StatefulWidget {
  const InviteMemberPage({super.key});

  @override
  State<InviteMemberPage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<InviteMemberPage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// Generate QR data
  ///
  /// This method generates a QR code based on the current userID, houseID,
  /// and the current timestamps, which ensures everytime the generated code is
  /// different
  ///
  /// Returns an encrypted JSON data including required values
  Future<String> generateQRData() async {
    User? user = FirebaseAuth.instance.currentUser;
    String householdId;

    if (user != null) {
      // gets UID and householdId from Firestore
      String userId = user.uid;
      QuerySnapshot querySnapshot = await firestore
          .collection('House')
          .where('Admin', isEqualTo: userId)
          .get();
      DocumentSnapshot houseDoc = querySnapshot.docs.first;
      householdId = houseDoc.id;

      // Generate a new timestamp on each call
      int timestamp = DateTime.now().millisecondsSinceEpoch;

      // Create Json object of above data, convert to QR code
      //    and returns encrypt the data
      Map<String, dynamic> qrInfo = {
        'userId': userId,
        'householdId': householdId,
        'timestamp': timestamp,
      };
      String qrData = jsonEncode(qrInfo);
      String encodedData = encryptData(qrData);
      return encodedData;
    } else {
      return Future.error("Before you can join a household, you must sign in.");
    }
  }

  /// Encryption Data Method
  ///
  /// [data] - the original data
  /// Helper method uses base64 to encode the original data
  ///
  /// Iteration Notes: can be replaced with more complex encryption
  /// algorithm in future iterations
  String encryptData(String data) {
    return base64Encode(utf8.encode(data));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text(
            "INVITE MEMBER QR CODE",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
            ),
            semanticsLabel: 'Invite member QR code',
          ),
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          ),
        ),
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            // Instructions of inviting member to a house
            // Wrapped in a RichText widget to display navigation info in bold text
            child: RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: "Show this QR code to the member to be invited.\n\n"
                        "The invitee should navigate to ",
                    semanticsLabel:
                        'Show this QR code to the member to be invited. The invitee should navigate to',
                  ),
                  TextSpan(
                    text: "'MyHouse' > 'Join Household'",
                    style: TextStyle(fontWeight: FontWeight.bold),
                    semanticsLabel: 'MyHouse > Join Household',
                  ),
                  TextSpan(
                    text:
                        " in the app and use the camera to scan this QR code. \n"
                        "Follow the prompts after scanning to complete the joining process.",
                    semanticsLabel:
                        ' in the app and use the camera to scan this QR code. Follow the prompts after scanning to complete the joining process',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          // QR code displaying
          FutureBuilder<String>(
            future: generateQRData(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                String qrData = snapshot.data!;
                return QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 200.0,
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return const CircularProgressIndicator();
              }
            },
          )
        ])));
  }
}
