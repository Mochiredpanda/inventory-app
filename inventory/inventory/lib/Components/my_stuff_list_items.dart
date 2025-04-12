import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

const Color themeColor = Color(0xff12CDD4);

/// MyStuffListItems Widget
/// 
/// A StatefulWidget that would be used in MyStuff page. Display the personal items in detailed,
/// including item's name, brand, purchased date, and date added. Using filter bar to filter out the 
/// results based on item location.
class MyStuffListItems extends StatefulWidget {
  final String selectedLocation;
  const MyStuffListItems({Key? key, required this.selectedLocation})
      : super(key: key);

  @override
  State<MyStuffListItems> createState() => _MyStuffListItemsState();
}

class _MyStuffListItemsState extends State<MyStuffListItems> {
  String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
  final db = FirebaseFirestore.instance;
  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
      .collection("Users")
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .collection("MyStuff")
      .snapshots();

  @override
  Widget build(BuildContext context) {
    // Using StreamBuilder to get the real time data from firestore database
    return StreamBuilder<QuerySnapshot>(
      stream: _usersStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        // Error handling when getting data
        if (snapshot.hasError) {
          return const Text('Something went wrong',
              semanticsLabel: 'Something went wrong');
        }
        // Display circularProgressIndicator when data is loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        // Iterate through the list of personal items, filter out the results based on location bar
        List<Widget> items =
            snapshot.data!.docs.where((DocumentSnapshot document) {
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          return widget.selectedLocation == 'SHOW ALL' ||
              data['location'] == widget.selectedLocation;
        }).map((DocumentSnapshot document) {
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          return _individualItem(data, document.id);
        }).toList();
        // If no item can be found that satisfy the filter options, return Empty Inventory
        if (items.isEmpty) {
          return _noItemToShow();
        }

        return ListView(
          children: items,
        );
      },
    );
  }

  /// Display the individual house item that satisfy the filter options, display item's basic information
  /// 
  /// [data] - data stream getting from the firestore database
  /// [itemId] - id of the personal item
  Widget _individualItem(Map<String, dynamic> data, String itemId) {
    // retrive image urls from json
    String? mainImageUrl = data['image'];

    return Container(
      padding: const EdgeInsets.only(top: 10, right: 30, left: 30, bottom: 10),
      width: double.infinity,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(
              color: themeColor,
              width: 3,
            ),
            fixedSize: const Size(200, 170),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: mainImageUrl != null
                    // keep placeholder for older version json support
                    ? Image.network(mainImageUrl, fit: BoxFit.cover)
                    : Image.asset('images/noImagePlaceholder.jpeg',
                        fit: BoxFit.cover),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 25, left: 30),
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(data['name'],
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5),
                              semanticsLabel: '${data['name']}'),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: <Widget>[
                            const Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text("Price:",
                                          style: TextStyle(color: Colors.black),
                                          semanticsLabel: 'Price'),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text("Brand:",
                                          style: TextStyle(color: Colors.black),
                                          semanticsLabel: 'Brand'),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text("Purchased Date:",
                                          style: TextStyle(color: Colors.black),
                                          semanticsLabel: 'Purchased Date'),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text("Date Added:",
                                          style: TextStyle(color: Colors.black),
                                          semanticsLabel: 'Date Added'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text('\$${data['price']}',
                                          style: const TextStyle(
                                              color: Colors.black),
                                          semanticsLabel: '${data['price']}'),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(data['brand'],
                                          style: const TextStyle(
                                              color: Colors.black),
                                          semanticsLabel: '${data['brand']}'),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(data['purchasedDate'],
                                          style: const TextStyle(
                                              color: Colors.black),
                                          semanticsLabel:
                                              '${data['purchasedDate']}'),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(data['dateAdded'],
                                          style: const TextStyle(
                                              color: Colors.black),
                                          semanticsLabel:
                                              '${data['dateAdded']}'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Each item would be clickable, which would navigate to item detail page
          onPressed: () {
            GoRouter.of(context)
                .go('/myStuffPage/individualItem/$currentUserId/$itemId');
          }),
    );
  }

  /// Display 'Empty Inventory' when there is no inventory to display that fits the filter options
  Widget _noItemToShow() {
    return const Center(
      child: Text("Empty Inventory",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
          semanticsLabel: 'Empty Inventory'),
    );
  }
}
