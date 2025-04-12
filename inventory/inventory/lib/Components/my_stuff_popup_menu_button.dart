import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// MyStuffPopupMenuButton Widget
/// 
/// A StatefulWidget allows user to add new item to personal inventory or export the list into
/// file format (future extension).
class MyStuffPopupMenuButton extends StatefulWidget {
  const MyStuffPopupMenuButton({super.key});

  @override
  State<MyStuffPopupMenuButton> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyStuffPopupMenuButton> {
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
          // Navigate to add item page when user selected first option
          if (result == 0) {
            GoRouter.of(context).go('/myStuffPage/addItem');
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry>[
          const PopupMenuItem(
            value: 0,
            child: Center(
              child: Text(
                'ADD ITEM',
                semanticsLabel: 'Add item',
              ),
            ),
          ),
          const PopupMenuItem(
            enabled: false,
            child: Center(
              child: Text('EXPORT MY STUFF', semanticsLabel: 'Export my stuff'),
            ),
          ),
        ],
      ),
    );
  }
}
