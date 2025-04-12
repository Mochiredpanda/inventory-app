import 'package:flutter/material.dart';
import '../FirebaseSettings/firestore_provider.dart';

/// HouseItemDetailPopUpMenuButton Widget
/// 
/// A StatefulWidget allows user to remove house item. The removal is only accessible by the admin
/// or the original owener of the item
class HouseItemDetailPopUpMenuButton extends StatefulWidget {
  final String houseId;
  final String itemId;
  const HouseItemDetailPopUpMenuButton(
      {required this.houseId, required this.itemId, super.key});

  @override
  State<HouseItemDetailPopUpMenuButton> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<HouseItemDetailPopUpMenuButton> {
  final firestoreProvider = FirestoreProvider();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: firestoreProvider.checkOwnership(widget.houseId, widget.itemId),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        }
        if (snapshot.hasError) {
          print("Error: ${snapshot.error}");
          return Container();
        }
        bool isOwner = snapshot.data ?? false;
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: PopupMenuButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            iconSize: 30,
            color: Colors.white,
            position: PopupMenuPosition.under,
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              PopupMenuItem(
                enabled: isOwner,
                child: const Center(
                  child: Text(
                    'REMOVE ITEM',
                    style: TextStyle(),
                    semanticsLabel: 'Remove Item',
                  ),
                ),
                onTap: () async {
                  if (isOwner) {
                    await firestoreProvider.deleteHouseItem(
                        widget.houseId, widget.itemId);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
