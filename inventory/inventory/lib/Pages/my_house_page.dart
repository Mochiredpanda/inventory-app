import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Components/my_house_popup_menu_button.dart';
import '../Components/my_house_list_items.dart';
import '../Components/my_house_location_filter.dart';
import '../Components/my_house_member_filter.dart';
import '../FirebaseSettings/firestore_provider.dart';

/// MyHousePage
///
/// A StatefulWidget that would contain two filter bars and the my_house_list_item widget.
/// Display the household items based on the filter selections
class MyHousePage extends StatefulWidget {
  const MyHousePage({super.key});

  @override
  State<MyHousePage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyHousePage> {
  String _selectedLocation = 'SHOW ALL';
  String _selectedMember = 'SHOW ALL';
  final firestoreProvider = FirestoreProvider();
  late Stream<QuerySnapshot> _myHouseStream;

  /// Set the initial state of the widget
  void initState() {
    super.initState();
    _myHouseStream = firestoreProvider.myHouseStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        automaticallyImplyLeading: false,
        title: const Text(
          "MY HOUSE",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
          ),
          semanticsLabel: 'My House',
        ),
        // Only provide the myHousePopupMenuButton if user is in a household
        // Not showing this option when user is not in a household
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: _myHouseStream,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                return const MyHousePopupMenuButton();
              } else {
                return Container();
              }
            },
          ),
        ],
      ),
      // Retrieving household data from firestore database
      body: StreamBuilder<QuerySnapshot>(
        stream: _myHouseStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text(
              'Something went wrong',
              semanticsLabel: 'Something went wrong',
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          // If user already in a household, display the item location and member filter bars
          return Column(
            children: [
              if (snapshot.data!.docs.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.only(left: 18, top: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Item Location",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      semanticsLabel: 'Item location',
                    ),
                  ),
                ),
              if (snapshot.data!.docs.isNotEmpty)
                MyHouseLocationFilter(
                  onLocationChanged: (location) {
                    setState(() {
                      _selectedLocation = location;
                    });
                  },
                ),
              if (snapshot.data!.docs.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.only(left: 18, top: 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Member",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      semanticsLabel: 'Member',
                    ),
                  ),
                ),
              if (snapshot.data!.docs.isNotEmpty)
                MyHouseMemberFilter(
                  onMemberChanged: (member) {
                    setState(() {
                      _selectedMember = member;
                    });
                  },
                ),
              Expanded(
                child: MyHouseListItems(
                    selectedLocation: _selectedLocation,
                    selectedMember: _selectedMember),
              ),
            ],
          );
        },
      ),
    );
  }
}
