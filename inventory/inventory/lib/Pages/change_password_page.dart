import 'package:flutter/material.dart';

/// Change Password Page
///
/// A StatefulWidget allows users to change their password.
/// Coordinates with buttons on MyProfile pages.
/// This page contains top bar and input fields for the old password,
/// new password, and confirmation of the new password, and a save button.
class ChangePasswordPage extends StatefulWidget {
  /// Constructs ChangePasswordPage.
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<ChangePasswordPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          "CHANGE PASSWORD",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
          ),
          semanticsLabel: 'Change password',
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Column of input fields
          Column(
            children: [
              _changePasswordInputBox("Old Password", topPadding: 40),
              _changePasswordInputBox("New Password"),
              _changePasswordInputBox("Confirm New Password"),
            ],
          ),
          Container(
            // save button container
            padding: const EdgeInsets.only(
                top: 10.0, left: 35.0, right: 35.0, bottom: 40.0),
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.black,
                textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1),
                fixedSize: const Size(200, 40),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7)),
              ),
              onPressed: () {
                debugPrint("Save");
              },
              child: const Text(
                "Save",
                semanticsLabel: 'Save',
              ),
            ),
          ),
        ],
      )),
    );
  }

  /// Creates an input box for password change page
  ///
  /// [text] - the label and prompt text for the input box
  /// [topPadding] - optional param to set the top padding of input box
  ///
  /// Returns a widget containing a label and a TextFormField for password input
  Widget _changePasswordInputBox(String text, {double topPadding = 20}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 35, top: topPadding, bottom: 5),
          child: Text(
            '$text*',
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
          padding: const EdgeInsets.only(left: 35, right: 35, bottom: 5),
          child: TextFormField(
            obscureText: true,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              hintText: text,
              hintStyle: const TextStyle(fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }
}
