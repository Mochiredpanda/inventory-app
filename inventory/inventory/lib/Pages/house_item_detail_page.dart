import 'package:flutter/material.dart';
import '../Components/house_item_detail_popup_menu_button.dart';
import '../FirebaseSettings/firestore_provider.dart';

const Color themeColor = Color(0xff12CDD4);

/// House Item Detail Page
/// 
/// A StatelessWidget that diplay the household item's details. Every information about this 
/// item would be displayed. If the information is not provided in the first place, the box
/// would return <Empty>
class HouseItemDetailPage extends StatelessWidget {
  final String houseId;
  final String itemId;
  const HouseItemDetailPage(
      {required this.houseId, required this.itemId, super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreProvider = FirestoreProvider();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'HOUSE ITEM',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
          ),
          semanticsLabel: 'House item',
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios, color: Color.fromARGB(255, 3, 3, 3)),
        ),
        actions: <Widget>[
          HouseItemDetailPopUpMenuButton(houseId: houseId, itemId: itemId)
        ],
      ),
      // Retrieve the item data from the firestore database
      body: FutureBuilder(
        future: firestoreProvider.fetchHouseItemData(houseId, itemId),
        builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          // Display circularProgressIndicator when data is loading
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

  /// Display house item's image
  /// 
  /// [imageUrl] - item's image url stored in firestore database
  /// [placeholderText] - items' image's placeholder text
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

  /// Boxes to display item's information in detailed
  /// 
  /// [itemData] - item's detail data retrieve from firestore database
  /// [attributes] - name of the fields/attributes stored in database
  /// [displayTab] - the title text of the boxes to display in this page
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
