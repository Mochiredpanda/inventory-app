import 'package:flutter/material.dart';

/// About Page
///
/// A StatelessWidget displaying the about information of the app.
///
/// It contains an AppBar with a back button and a body with text details.
class AboutPage extends StatelessWidget {
  /// Constructs AboutPage
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('ABOUT THIS APP',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
            ),
            semanticsLabel: 'About this app'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
      ),
      body: const Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Text widgets in Padding displaying information about the app
          //   and its creators.
          Padding(
            padding: EdgeInsets.only(left: 37.0, right: 37.0),
            child: Text(
                "This mobile application was made as part of a cumulative project for CS5520: Mobile Application Development at Northeastern University for Fall of 2023.\n",
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 16.0,
                ),
                semanticsLabel:
                    'This mobile application was made as part of a cumulative project for CS5520: Mobile Application Development at Northeastern University for Fall of 2023.'),
          ),
          Padding(
            padding: EdgeInsets.only(left: 37.0, right: 37.0),
            child: Text(
              "This Amazing App Was Made By\n",
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16.0,
              ),
              semanticsLabel: 'This Amazing App Was Made By',
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 37.0, right: 37.0),
            child: Text(
              "The AVENGERS\n",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
              semanticsLabel: 'The AVENGERS',
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 37.0, right: 37.0),
            child: Text(
              "Steve Chen\nJiyu He\nKabila Williams\nAndrew Moran\n",
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16.0,
              ),
              semanticsLabel: 'Steve Chen Jiyu He Kabila Williams Andrew Moran',
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 37.0, right: 37.0),
            child: Text(
              "©2023",
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16.0,
              ),
              semanticsLabel: '2023',
            ),
          ),
        ],
      )),
    );
  }
}
