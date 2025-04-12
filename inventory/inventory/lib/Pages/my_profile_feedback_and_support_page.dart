import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Feedback and Support Page
///
/// A StatelessWidget that displays the info about feedback and team contacts
/// Includes clickable buttons redirects to github repository and a pseudo email
/// To be updated with more info in future iteration

// Global variable storing contact info in URL objects
final Uri _url =
    Uri.parse('https://github.com/your_username/finalproject-avengers');
final Uri _email = Uri(
  scheme: 'mailto',
  path: 'inventoryEmail@gmail.com',
);

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  /// Launches the Github URL
  ///
  /// Opens Github page for this project.
  /// Handles launch error by throwing exceptions
  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  /// Launches the Email app
  ///
  /// Opens default email app with preset email address
  /// Handles launch error by throwing exceptions
  Future<void> _launchEmail() async {
    if (!await launchUrl(_email)) {
      throw Exception('Could not launch $_email');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        automaticallyImplyLeading: false,
        title: const Text(
          "FEEDBACK & SUPPORT",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
          ),
          semanticsLabel: 'Feedback and support',
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Description of feedback and support page
            const Padding(
              padding: EdgeInsets.only(left: 37.0, right: 37.0),
              child: Text(
                "For feedback and support, please reach out via the following contact information:\n",
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 16.0,
                ),
                semanticsLabel:
                    'For feedback and support, please reach out via the following contact information:',
              ),
            ),
            // Github link button
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.code),
                label: const Text('GitHub Address'),
                key: const Key('GitHub Address'),
                onPressed: _launchUrl,
              ),
            ),
            // Email preset button
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.email),
                label: const Text('InventoryApp@gmail.com'),
                key: const Key("email Address"),
                onPressed: _launchEmail,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
