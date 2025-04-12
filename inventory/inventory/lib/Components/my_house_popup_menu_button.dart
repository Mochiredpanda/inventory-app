import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// MyHousePopUpMenuButton Widget
/// 
/// A StatefulWidget allows user to invite new member to the household or leave the household (future extension).
/// This popup menu button would only be accessible after a user joined a household
class MyHousePopupMenuButton extends StatefulWidget {
  const MyHousePopupMenuButton({super.key});

  @override
  State<MyHousePopupMenuButton> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyHousePopupMenuButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: PopupMenuButton<int>(
        icon: const Icon(Icons.people, color: Colors.black),
        iconSize: 30,
        color: Colors.white,
        position: PopupMenuPosition.under,
        onSelected: (result) {
          // Navigate to invite memeber page once selected the first option
          if (result == 0) {
            GoRouter.of(context).go('/myHousePage/inviteMemberPage');
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
          const PopupMenuItem(
            value: 0,
            child: Center(
              child: Text('INVITE MEMBER', semanticsLabel: 'Invite member'),
            ),
          ),
          const PopupMenuItem(
            value: 1,
            enabled: false,
            child: Center(
              child: Text('LEAVE HOUSEHOLD',
                  semanticsLabel: 'Leave household'),
            ),
          ),
        ],
      ),
    );
  }
}
