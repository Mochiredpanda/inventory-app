import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Components/item_detail_popup_menu_button.dart';

/// ItemDetailPage
///
/// A StatelessWidget that displays an Item details that fetched from the database

// Global helper var to set the Main theme color
const Color themeColor = Color(0xff12CDD4);

class ItemDetailPage extends StatelessWidget {
  final String userId;
  final String itemId;
  const ItemDetailPage({required this.userId, required this.itemId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'INDIVIDUAL ITEM',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
          ),
          semanticsLabel: 'Individual item',
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
        actions: <Widget>[
          ItemDetailPopUpMenuButton(userId: userId, itemId: itemId)
        ],
      ),
      body: FutureBuilder(
        future: _fetchItemData(),
        builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text(
                "Error! Something went wrong",
                semanticsLabel: 'Error! Something went wrong',
              ),
            );
          } else {
            // fetch data and image urls for display
            Map<String, dynamic> itemData = snapshot.data!;
            String? mainImageUrl = itemData['image'];
            String? receiptImageUrl = itemData['receipt'];
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                child: Form(
                  child: Column(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        height: 40,
                        width: double.infinity,
                        child: Center(
                          child: Text(
                            itemData['name'],
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1),
                            semanticsLabel: itemData['name'],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      // Main Image uploads and imagePicker buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          // Thumbnail display box
                          Container(
                            width: 150.0,
                            height: 150.0,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: _displayImage(
                                mainImageUrl, 'No main image available'),
                          ),
                          const SizedBox(width: 35),
                          const SizedBox(width: 35),
                          Expanded(
                            child: Column(
                              children: [
                                // Price & Brand in a Column
                                _itemDetailBox(itemData, 'price', 'Price'),
                                const SizedBox(height: 20),
                                // Item Brand Field (Text)
                                //    Currently implemented as REQUIRED
                                _itemDetailBox(itemData, 'brand', 'Brand')
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Row 2: Dates
                      Row(
                        children: <Widget>[
                          Expanded(
                              // Purchased Date Field
                              child: _itemDetailBox(
                                  itemData, 'purchasedDate', 'Purchased Date')),
                          const SizedBox(width: 10),
                          Expanded(
                              // Added Date Field
                              child: _itemDetailBox(
                                  itemData, 'dateAdded', 'Date Added')),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: <Widget>[
                          Expanded(
                              // Purchased Date Field
                              child: _itemDetailBox(
                                  itemData, 'location', 'Item Location')),
                          const SizedBox(width: 10),
                          Expanded(
                              // Added Date Field
                              child: _itemDetailBox(itemData, 'purchaseMethod',
                                  'Purchased Method')),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _itemDetailBox(itemData, 'purchasedAt', 'Purchased At'),
                      const SizedBox(height: 20),
                      _itemDetailBox(itemData, 'notes', 'Notes'),
                      const SizedBox(height: 20),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 5),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Receipt',
                            semanticsLabel: 'Receipt',
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 150.0,
                          height: 150.0,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: _displayImage(
                              receiptImageUrl, 'No receipt image available'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  /// Fetch Item data
  ///
  /// Helper method to fetch the Item data from firabase database based on
  /// the current userId and the itemId
  ///
  /// Returns the Item data in a Map data structure
  Future<Map<String, dynamic>> _fetchItemData() async {
    String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final db = FirebaseFirestore.instance;
    final itemRef = db
        .collection("Users")
        .doc(currentUserId)
        .collection("MyStuff")
        .doc(itemId);

    DocumentSnapshot doc = await itemRef.get();
    return doc.data() as Map<String, dynamic>;
  }

  /// Display Image in Container
  ///
  /// [imageUrl] - image url from database
  /// [placeholderText] - prompt text used in the container as placeholder
  Widget _displayImage(String? imageUrl, String placeholderText) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(imageUrl,
          fit: BoxFit.cover, width: 150, height: 150);
    } else {
      return Container(
        width: 150,
        height: 150,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          placeholderText,
          semanticsLabel: placeholderText,
        ),
      );
    }
  }

  /// Item detail Box
  ///
  /// Returns a widget box used to display the attribute value of the Item
  Widget _itemDetailBox(
      Map<String, dynamic> itemData, String attributes, String displayTab) {
    String displayAttributes = itemData[attributes];
    if (attributes == 'price') {
      displayAttributes = '\$$displayAttributes';
    }
    if (itemData[attributes] == "") {
      displayAttributes = "< Empty >";
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              displayTab,
              semanticsLabel: displayTab,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: themeColor,
            ),
          ),
          height: 40,
          width: double.infinity,
          child: Center(
            child: Text(
              displayAttributes,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              semanticsLabel: displayAttributes,
            ),
          ),
        ),
      ],
    );
  }
}
