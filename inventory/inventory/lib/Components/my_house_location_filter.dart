import 'package:flutter/material.dart';

/// MyHouseLocationFilter Widget
/// 
/// A StatefulWidget that used to filter the household items based on the item's location
/// selected by the user. Contains a list of default rooms.
class MyHouseLocationFilter extends StatefulWidget {
  final Function(String) onLocationChanged;
  const MyHouseLocationFilter({Key? key, required this.onLocationChanged})
      : super(key: key);

  @override
  State<MyHouseLocationFilter> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyHouseLocationFilter> {
  final List<String> _houseItemLocations = [
    'Bedroom #1',
    'Bedroom #2',
    'Kitchen',
    'Living Room',
    'Bathroom',
    'Garage',
    'Dining Room'
  ];
  String _selectedHouseLocation = 'SHOW ALL';
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 5),
      child: SizedBox(
        height: 50, // Set the height as needed
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _filterOptions("SHOW ALL", _selectedHouseLocation == 'SHOW ALL'),
            ..._houseItemLocations.map((location) =>
                _filterOptions(location, _selectedHouseLocation == location)),
          ],
        ),
      ),
    );
  }

  /// Set the state of the filter options based on the user's selection
  /// 
  /// [location] - the item location user selected in filter bar
  /// [isSelected] - the state of the filter options. The color of the button would be 
  /// different based on if user select it or not
  Widget _filterOptions(String location, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: OutlinedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
            isSelected ? Theme.of(context).primaryColor : Colors.white,
          ),
          foregroundColor: MaterialStateProperty.all<Color>(
            Colors.black,
          ),
          side: MaterialStateProperty.all<BorderSide>(
            BorderSide(
              color: Theme.of(context).primaryColor,
            ),
          ),
          textStyle: MaterialStateProperty.all<TextStyle>(
            const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        onPressed: () {
          widget.onLocationChanged(location);
          setState(
            () {
              _selectedHouseLocation = location;
            },
          );
          // Handle button press
        },
        child: Text(
          location,
          semanticsLabel: location,
        ),
      ),
    );
  }
}
