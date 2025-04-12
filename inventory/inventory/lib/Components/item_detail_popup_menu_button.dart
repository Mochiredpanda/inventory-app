import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../FirebaseSettings/firestore_provider.dart';
import 'package:logger/logger.dart';

/// ItemDetailPopUpMenuButton
///
/// A StatefulWidget displays a dropdown menu on ItemDetail page, contains
/// operation buttons to edit, share to house, or remove the current Item.

// Initialize the logger for error handling
var logger = Logger();

class ItemDetailPopUpMenuButton extends StatefulWidget {
  final String userId;
  final String itemId;
  const ItemDetailPopUpMenuButton(
      {required this.userId, required this.itemId, super.key});

  @override
  State<ItemDetailPopUpMenuButton> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<ItemDetailPopUpMenuButton> {
  final firestoreProvider = FirestoreProvider();

  /// Delete Images from Storage
  ///
  /// Helper method to optimize data storaging when delete one item the images
  /// stored with the object on database will be removed.
  ///
  /// [imageUrl] - the url on firebase storage to be removed
  ///
  Future<void> _deleteImageFromStorage(String imageUrl) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference imageRef = storage.refFromURL(imageUrl);
      await imageRef.delete();
      logger.e('Image deleted successfully');
    } catch (e) {
      logger.e('Error deleting image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: firestoreProvider.myHouseStream(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: PopupMenuButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              iconSize: 30,
              color: Colors.white,
              position: PopupMenuPosition.under,
              onSelected: (result) {
                if (result == 0) {
                  // navigate to the goal item page
                  GoRouter.of(context).go(
                      '/myStuffPage/editItem/${widget.userId}/${widget.itemId}');
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                // button to edit item
                const PopupMenuItem(
                  value: 0,
                  child: Center(
                    child: Text(
                      'EDIT ITEM',
                      semanticsLabel: 'Edit Item',
                    ),
                  ),
                ),
                PopupMenuItem(
                    // button to share item to house
                    // if current user is in a house
                    enabled: snapshot.data!.docs.isNotEmpty,
                    child: const Center(
                      child: Text(
                        'SHARE TO HOUSE',
                        semanticsLabel: 'Share to House',
                      ),
                    ),
                    onTap: () async {
                      await firestoreProvider.transferItemToHouse(
                          snapshot.data!.docs[0].id,
                          widget.userId,
                          widget.itemId);
                      Navigator.of(context).pop();
                    }),
                PopupMenuItem(
                    // button to remove item
                    child: const Center(
                      child: Text(
                        'REMOVE ITEM',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                        semanticsLabel: 'Remove Item',
                      ),
                    ),
                    onTap: () async {
                      // when removed, the related images will also be removed
                      Map<String, dynamic> itemData =
                          await firestoreProvider.fetchItemData(widget.itemId);
                      if (itemData['image'] != null) {
                        await _deleteImageFromStorage(itemData['image']);
                      }
                      if (itemData['receipt'] != null) {
                        await _deleteImageFromStorage(itemData['receipt']);
                      }
                      await firestoreProvider.deleteItem(
                          widget.userId, widget.itemId);
                      _showDeletedWindow();
                      Navigator.of(context).pop();
                    }),
              ],
            ),
          );
        });
  }

  /// Popup window of Notice
  ///
  /// Helper method to trigger a popup dialog to inform the user that
  /// the current item is removed successfully
  void _showDeletedWindow() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Success',
            semanticsLabel: 'Success',
          ),
          content: const Text(
            'Item successfully removed.',
            semanticsLabel: 'Item successfully removed',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'OK',
                semanticsLabel: 'Ok to close popup window',
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }
}
