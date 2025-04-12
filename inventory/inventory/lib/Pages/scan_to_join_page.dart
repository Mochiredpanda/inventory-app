import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

/// ScanToJoinPage
///
/// A Statefull widget allows users to use camera to scan QR code and join a house
/// The camera is setup to read QR code and decode the invitation QR code to JSON
/// and validate the current time with the timestamp in the invitation code.
/// If read valid code, the current user will be added to the House and the
/// houseId will be added to the user account.
class ScanToJoinPage extends StatefulWidget {
  const ScanToJoinPage({super.key});

  @override
  State<ScanToJoinPage> createState() => _ScanToJoinPageState();
}

class _ScanToJoinPageState extends State<ScanToJoinPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  final TextEditingController qrTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkForCameraPermission();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  /// Check for camera permission
  ///
  /// Ask the user to provide camera permission and send permission request
  /// If user declined request, call a popup window and go back
  Future<void> _checkForCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      // Request camera permission
      status = await Permission.camera.request();

      // If permission still not granted, navigate to MyHouse page
      if (!status.isGranted) {
        _showPopupWindow('Camera Permission Required',
            'Camera permission is required to scan QR codes.');
      }
    }
  }

  /// Decode the QR code
  ///
  /// Helper method used to decode the QR code and get the JSON object
  /// [encryptedData] - the data to be decrypted
  String _decryptData(String encryptedData) {
    return utf8.decode(base64Decode(encryptedData));
  }

  /// Popup window
  ///
  /// Helper method returns a popup dialog and navigate to the last page
  /// [title] - string of popup window title
  /// [message] - string of prompt displayed in the dialog window
  ///
  void _showPopupWindow(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            semanticsLabel: title,
          ),
          content: Text(
            message,
            semanticsLabel: message,
          ),
          actions: <Widget>[
            // clickable button to continue
            TextButton(
              child: const Text(
                'OK',
                semanticsLabel: 'Ok',
              ),
              onPressed: () {
                // Close the dialog
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Join Household
  ///
  /// Helper method to add the current user to a house after the invitation
  /// data decoded; It handled cases of data conflicts
  /// [houseId] - The houseId in database to be joined
  /// [userId] - The userId in database to join the house
  Future<void> _joinHousehold(String houseId, String userId) async {
    // fetch reference
    DocumentReference houseRef =
        FirebaseFirestore.instance.collection("House").doc(houseId);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot houseSnapshot = await transaction.get(houseRef);
      // if cannot find houseId on firebase
      if (!houseSnapshot.exists) {
        throw Exception("House does not exist!");
      }

      DocumentReference userHouseRef = FirebaseFirestore.instance
          .collection("Users")
          .doc(userId)
          .collection("MyHouse")
          .doc(houseId);
      await userHouseRef.set({
        'houseId': houseId,
      });

      // fetch the member list and validate the current user
      List<dynamic> members = List.from(houseSnapshot['Member']);
      if (!members.contains(userId)) {
        members.add(userId);
        transaction.update(houseRef, {'Member': members});
      } else {
        _showPopupWindow('Hey!', 'You are already a member of this household.');
      }
    }).catchError((error) {
      _showPopupWindow('Error!', 'Failed to join the household: $error');
    });
  }

  /// QR Reader to Join House
  ///
  /// Helper method associated with onQRViewCreated event, it scans the QR code
  /// and controls camera, handles QR code reading
  ///
  /// [controller] - the controller identifier of QRViewController
  ///
  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;

    // fetch user and userId
    User? user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    controller.scannedDataStream.listen((scanData) {
      if (userId == null) {
        _showPopupWindow('Error', 'You must be logged in to join a household.');
        return;
      }
      // Attempt to decode the scanned data and validate
      try {
        controller.pauseCamera();
        final decryptedData = _decryptData(scanData.code.toString());
        final data = jsonDecode(decryptedData);
        // Check timestamp is within 15 mins
        final int timestamp = data['timestamp'];
        if (DateTime.now().millisecondsSinceEpoch - timestamp <
            15 * 60 * 1000) {
          final String houseId = data['householdId'];
          _joinHousehold(houseId, userId);
          // success and route back to myHouse
          // need to refresh to display new member filter on myHouse page
          _showPopupWindow(
              'Success', 'You have successfully joined the household!');
          GoRouter.of(context).go('/myHousePage');
        } else {
          _showPopupWindow(
              'Expired QR Code', 'This QR code is expired. Please try again.');
        }
      } catch (e) {
        _showPopupWindow(
            'Invalid QR Code', 'Could not read QR code. Please try again.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Join Household',
          semanticsLabel: 'Join Household',
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Theme.of(context).primaryColor,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
