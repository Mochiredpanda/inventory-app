import 'package:flutter/material.dart';
import '../FirebaseSettings/firestore_provider.dart';
import 'package:logger/logger.dart';

/// Create Household Page
///
/// A StatelessWidget that guide the users to create a household
/// and set the current user as the admin of the House.
/// It contains a top bar and text guidance, and a create household button.

// Initialize the logger for error handling
var logger = Logger();

class CreateHouseholdPage extends StatelessWidget {
  const CreateHouseholdPage({super.key});

  /// Create Household Method
  ///
  /// Helper method to generate a HouseId from firebase database
  /// and set the current UserId as the admin of the House object
  void _createHousehold() async {
    try {
      FirestoreProvider firestoreProvider = FirestoreProvider();
      String houseDocId = await firestoreProvider.createHousehold();
      await firestoreProvider.addUserToHousehold(
          firestoreProvider.currentUserId, houseDocId);
    } catch (e) {
      logger.e('Error when creating household: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
        title: const Text(
          "CREATE HOUSEHOLD",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
          ),
          semanticsLabel: 'Create household',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 40, right: 40),
        child: Column(
          // Column of Creating household instructions and notes
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'You are about to create a new household.',
                style: TextStyle(fontSize: 18),
                semanticsLabel: 'You are about to create a new household',
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'You will be made the admin of the new household.You will be able to choose to transfer this to another memeber of the household.',
                style: TextStyle(fontSize: 18),
                semanticsLabel:
                    'You will be made the admin of the new household. You will be able to choose to transfer this to another member of the household',
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Once created you will be able to invite new members to the household.',
                style: TextStyle(fontSize: 18),
                semanticsLabel:
                    'Once created you will be able to invite new members to the household.',
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            // Button to confirm creating household
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.black,
                textStyle:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                fixedSize: const Size(200, 40),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7)),
              ),
              onPressed: () {
                _createHousehold();
                Navigator.of(context).pop();
              },
              child: const Text(
                'CREATE HOUSEHOLD',
                semanticsLabel: 'Create household',
              ),
            )
          ],
        ),
      ),
    );
  }
}
