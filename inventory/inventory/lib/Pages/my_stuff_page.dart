import 'package:flutter/material.dart';
import '../Components/my_stuff_popup_menu_button.dart';
import '../Components/my_stuff_list_items.dart';
import '../Components/my_stuff_location_filter.dart';

/// MyStuffPage
///
/// A StatefulWidget that would contain a filter bar and the my_stuff_list_item widget.
/// Display the personal items based on the filter selections
class MyStuffPage extends StatefulWidget {
  const MyStuffPage({super.key});

  @override
  State<MyStuffPage> createState() => _MyStuffPageState();
}

class _MyStuffPageState extends State<MyStuffPage> {
  String _selectedLocation = 'SHOW ALL';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          "MY STUFF",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
          ),
          semanticsLabel: 'My Stuff',
        ),
        automaticallyImplyLeading: false,
        actions: const <Widget>[MyStuffPopupMenuButton()],
      ),
      body: Column(
        children: [
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
                semanticsLabel: 'Item Location',
              ),
            ),
          ),
          // My Stuff location filter bar
          MyStuffLocationFilter(
            onLocationChanged: (location) {
              setState(() {
                _selectedLocation = location;
              });
            },
          ),
          Expanded(
              child: MyStuffListItems(selectedLocation: _selectedLocation)),
        ],
      ),
    );
  }
}
