import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../FirebaseSettings/firestore_provider.dart';

const Color themeColor = Color(0xff12CDD4);

/// MyHouseListItems Widget
/// 
/// A StatefulWidget that would be used in MyHouse page. Display the household items in detailed,
/// including item's name, brand, purchased date, and date added. Using filter bar to filter out the 
/// results based on item location and member in the household.
class MyHouseListItems extends StatefulWidget {
  final String selectedLocation;
  final String selectedMember;
  const MyHouseListItems(
      {Key? key, required this.selectedLocation, required this.selectedMember})
      : super(key: key);

  @override
  State<MyHouseListItems> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyHouseListItems> {
  final firestoreProvider = FirestoreProvider();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // Get MyHouse Stream
      stream: firestoreProvider.myHouseStream(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        // Check if snapshot has error
        if (snapshot.hasError) {
          return const Text(
            'Something went wrong',
            semanticsLabel: 'Something went wrong',
          );
        }
        // Give circularProgressIndicator when data is loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.data!.docs.isEmpty) {
          // If data is empty, meaning user has not joined any household yet, MyHouse page would
          // ask if user wants to create household or join a household
          return Center(
              child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                // Button to create a household
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.black,
                    textStyle: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w900),
                    fixedSize: const Size(200, 40),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7)),
                  ),
                  onPressed: () {
                    GoRouter.of(context).go('/myHousePage/createHouseholdPage');
                  },
                  child: const Text(
                    'CREATE HOUSEHOLD',
                    semanticsLabel: 'Create household',
                  ),
                ),
                const SizedBox(height: 20),
                // Button to join a household
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.black,
                    textStyle: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w900),
                    fixedSize: const Size(200, 40),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7)),
                  ),
                  onPressed: () {
                    GoRouter.of(context).go('/myHousePage/joinHouseholdPage');
                  },
                  child: const Text(
                    'JOIN HOUSEHOLD',
                    semanticsLabel: 'Join household',
                  ),
                ),
              ]));
        } else {
          // User is within a household, display the household items
          String myHouseId = snapshot.data!.docs[0].id;
          return StreamBuilder<QuerySnapshot>(
            stream: firestoreProvider.houseItemStream(myHouseId),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              // Error handling
              if (snapshot.hasError) {
                return const Text(
                  'Something went wrong',
                  semanticsLabel: 'Something went wrong',
                );
              }
              // Give circularProgressIndicator when data is loading
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              // Iterate through the list of household items, filter out the results based on location and member
              // filter bars
              List<Widget> items =
                  snapshot.data!.docs.where((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                return (widget.selectedLocation == 'SHOW ALL' ||
                        data['location'] == widget.selectedLocation) &&
                    (widget.selectedMember == 'SHOW ALL' ||
                        data['ownerFullName'] == widget.selectedMember);
              }).map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                return _individualItem(data, document.id, myHouseId);
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
      },
    );
  }

  /// Display the individual house item that satisfy the filter options, display item's basic information
  /// 
  /// [data] - data stream getting from the firestore database
  /// [itemId] - each household item's id
  /// [houseId] - household id
  Widget _individualItem(
      Map<String, dynamic> data, String itemId, String houseId) {
    // retrive image urlss from json
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
                          child: Text(
                            data['name'],
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5),
                            semanticsLabel: '${data['name']}',
                          ),
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
                                      child: Text(
                                        "Price:",
                                        style: TextStyle(color: Colors.black),
                                        semanticsLabel: 'Price',
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "Brand:",
                                        style: TextStyle(color: Colors.black),
                                        semanticsLabel: 'Brand',
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "Purchased Date:",
                                        style: TextStyle(color: Colors.black),
                                        semanticsLabel: 'Purchased Date',
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "Date Added:",
                                        style: TextStyle(color: Colors.black),
                                        semanticsLabel: 'Date Added',
                                      ),
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
                                      child: Text(
                                        '\$${data['price']}',
                                        style: const TextStyle(
                                            color: Colors.black),
                                        semanticsLabel: '${data['price']}',
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        data['brand'],
                                        style: const TextStyle(
                                            color: Colors.black),
                                        semanticsLabel: '${data['brand']}',
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        data['purchasedDate'],
                                        style: const TextStyle(
                                            color: Colors.black),
                                        semanticsLabel:
                                            '${data['purchasedDate']}',
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        data['dateAdded'],
                                        style: const TextStyle(
                                            color: Colors.black),
                                        semanticsLabel: '${data['dateAdded']}',
                                      ),
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
                .go('/myHousePage/individualHouseItem/$houseId/$itemId');
          }),
    );
  }

  /// Display 'Empty Inventory' when there is no inventory to display that fits the filter options
  Widget _noItemToShow() {
    return const Center(
      child: Text(
        "Empty Inventory",
        style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
        semanticsLabel: 'Empty Inventory',
      ),
    );
  }
}
