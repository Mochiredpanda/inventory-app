import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// MyProfilePopupMenuButton
///
/// A StatefulWidget displays a dropdown menu on MyProfile page, contains
/// operation buttons to Edit profile, Support, About Page, and logout.
///
class MyProfilePopupMenuButton extends StatefulWidget {
  const MyProfilePopupMenuButton({super.key});

  @override
  State<MyProfilePopupMenuButton> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyProfilePopupMenuButton> {
  void signUserOut() {
    FirebaseAuth.instance.signOut();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: PopupMenuButton(
        icon: const Icon(Icons.menu, color: Colors.black),
        iconSize: 30,
        color: Colors.white,
        position: PopupMenuPosition.under,
        onSelected: (result) {
          if (result == 0) {
            GoRouter.of(context).go('/myProfilePage/editProfile');
          }
          if (result == 1) {
            GoRouter.of(context).go('/myProfilePage/support');
          }
          if (result == 2) {
            GoRouter.of(context).go('/myProfilePage/about');
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry>[
          const PopupMenuItem(
            value: 0,
            child: Center(
              child: Text('EDIT PROFILE', semanticsLabel: 'Edit profile'),
            ),
          ),
          const PopupMenuItem(
            value: 1,
            child: Center(
              child: Text('SUPPORT', semanticsLabel: 'Support'),
            ),
          ),
          const PopupMenuItem(
            value: 2,
            child: Center(
              child: Text('ABOUT', semanticsLabel: 'About'),
            ),
          ),
          PopupMenuItem(
            value: 3,
            onTap: signUserOut,
            child: const Center(
              child: Text('LOG OUT',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                  semanticsLabel: 'Log out'),
            ),
          ),
        ],
      ),
    );
  }
}
