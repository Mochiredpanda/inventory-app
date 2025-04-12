import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../FirebaseSettings/firestore_provider.dart';

/// MyHouseMemberFilter Widget
/// 
/// A StatefulWidget that used to filter the household items based on the member within the household
/// selected by the user. Fetching the data from firestore to list out all the members
class MyHouseMemberFilter extends StatefulWidget {
  final Function(String) onMemberChanged;
  const MyHouseMemberFilter({Key? key, required this.onMemberChanged})
      : super(key: key);

  @override
  State<MyHouseMemberFilter> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyHouseMemberFilter> {
  final firestoreProvider = FirestoreProvider();

  final List<String> _houseMember = [];
  String _selectedMember = 'SHOW ALL';

  @override
  Widget build(BuildContext context) {
    // Using FutureBuilder to retrieve all the members data from the firestore data
    return FutureBuilder<DocumentSnapshot>(
        future: firestoreProvider.getHouseMember(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text(
              'Something went wrong',
              semanticsLabel: 'Something went wrong',
            );
          }
          if (snapshot.hasData) {
            if (_houseMember.isEmpty) {
              final houseMemberData =
                  snapshot.data!.data() as Map<String, dynamic>;
              List<String> memberIds =
                  List<String>.from(houseMemberData['Member']);
              Future.wait(
                memberIds.map(
                    (memberId) => firestoreProvider.fetchMemberData(memberId)),
              ).then((List<String> memberNames) {
                _houseMember.addAll(memberNames);
                setState(() {});
              });
            }
            return Padding(
              padding:
                  const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 5),
              child: SizedBox(
                height: 50, // Set the height as needed
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _filterOptions("SHOW ALL", _selectedMember == 'SHOW ALL'),
                    ..._houseMember.map((member) =>
                        _filterOptions(member, _selectedMember == member)),
                  ],
                ),
              ),
            );
          } else {
            return Container();
          }
        });
  }

  /// Set the state of the filter options based on the user's selection
  /// 
  /// [member] - the member within the household user selected in filter bar
  /// [isSelected] - the state of the filter options. The color of the button would be 
  /// different based on if user select it or not
  Widget _filterOptions(String member, bool isSelected) {
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
          widget.onMemberChanged(member);
          setState(
            () {
              _selectedMember = member;
            },
          );
          // Handle button press
        },
        child: Text(member, semanticsLabel: member),
      ),
    );
  }
}
