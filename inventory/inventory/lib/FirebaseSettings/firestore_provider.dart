import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// FirestoreProvider
/// 
/// The central page of calling, accessing, edit, and deleting data from the firestore
class FirestoreProvider {
  static final FirestoreProvider _instance = FirestoreProvider._internal();

  factory FirestoreProvider() {
    return _instance;
  }

  FirestoreProvider._internal();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Getting the current user id
  String? get currentUserId => _auth.currentUser?.uid;

  // Getting current user's personal information
  Future<Map<String, dynamic>> fetchUserData() async {
    final userRef = _firestore.collection("Users").doc(currentUserId);
    DocumentSnapshot doc = await userRef.get();
    return doc.data() as Map<String, dynamic>;
  }

  // Get user data stream (real-time updated data)
  Stream<DocumentSnapshot> fetchUserDataStream() {
    return _firestore.collection("Users").doc(currentUserId).snapshots();
  }

  // Get myStuff stream (real-time updated data)
  Stream<QuerySnapshot> myStuffStream() {
    return _firestore
        .collection("Users")
        .doc(currentUserId)
        .collection("MyStuff")
        .snapshots();
  }

  // Get myHouse stream (real-time updated data)
  Stream<QuerySnapshot> myHouseStream() {
    return _firestore
        .collection("Users")
        .doc(currentUserId)
        .collection("MyHouse")
        .snapshots();
  }

  // Get houseItem stream (real-time updated data)
  Stream<QuerySnapshot> houseItemStream(String myHouseId) {
    return _firestore
        .collection("House")
        .doc(myHouseId)
        .collection("HouseItem")
        .snapshots();
  }

  // Get the list of house members
  Future<DocumentSnapshot> getHouseMember() async {
    QuerySnapshot querySnapshot = await myHouseStream().first;
    String myHouseId = querySnapshot.docs[0].id;
    return _firestore.collection("House").doc(myHouseId).get();
  }

  // Create a household, user will get a new collection called MyHouse and a reference id to that House
  // A new House document would be created and will have a same id as the one stored by the user
  Future<String> createHousehold() async {
    try {
      CollectionReference houseCollection = _firestore.collection("House");
      DocumentReference houseDoc = houseCollection.doc();

      List<String?> list = [currentUserId];
      final data = <String, dynamic>{
        "Admin": currentUserId,
        "Member": list,
      };
      await houseDoc.set(data);
      return houseDoc.id;
    } catch (e) {
      print('Error creating household');
      rethrow;
    }
  }

  // Adding new member to the household
  Future<void> addUserToHousehold(
      String? userId, String houseDocumentId) async {
    try {
      await _firestore
          .collection("Users")
          .doc(userId)
          .collection("MyHouse")
          .doc(houseDocumentId)
          .set({});
    } catch (e) {
      print('Error adding user to household');
      rethrow; // Rethrow the exception to propagate it to the caller
    }
  }

  // Having member's id, get member's first and last name
  Future<String> fetchMemberData(String memberId) async {
    DocumentSnapshot memberSnapshot =
        await _firestore.collection("Users").doc(memberId).get();
    Map<String, dynamic> memberData =
        memberSnapshot.data() as Map<String, dynamic>;
    return '${memberData['FirstName']} ${memberData['LastName']}';
  }

  // Check the ownership of the hosuehold item. Household item will have a field indicating the origianl
  // owenr's id. Use that id to check if the current admin or the current user can remove this item from the 
  // household
  Future<bool> checkOwnership(String houseId, String houseItemId) async {
    try {
      final houseItemSnapshot = await _firestore
          .collection("House")
          .doc(houseId)
          .collection("HouseItem")
          .doc(houseItemId)
          .get();
      final houseSnapshot =
          await _firestore.collection("House").doc(houseId).get();
      if (houseItemSnapshot.exists && houseSnapshot.exists) {
        final adminId = houseSnapshot['Admin'];
        final ownerId = houseItemSnapshot['owner'];

        return adminId == currentUserId || currentUserId == ownerId;
      }
      return false;
    } catch (e) {
      print('Error checking ownership: $e');
      return false;
    }
  }

  // Get item's data
  Future<Map<String, dynamic>> fetchItemData(String itemId) async {
    final itemRef = _firestore
        .collection("Users")
        .doc(currentUserId)
        .collection("MyStuff")
        .doc(itemId);
    DocumentSnapshot doc = await itemRef.get();
    return doc.data() as Map<String, dynamic>;
  }

  // Get household item's data
  Future<Map<String, dynamic>> fetchHouseItemData(
      String houseId, String itemId) async {
    final itemRef = _firestore
        .collection("House")
        .doc(houseId)
        .collection("HouseItem")
        .doc(itemId);
    DocumentSnapshot doc = await itemRef.get();
    return doc.data() as Map<String, dynamic>;
  }

  // Delete a personal item
  Future<void> deleteItem(String userId, String itemId) {
    return _firestore
        .collection("Users")
        .doc(userId)
        .collection("MyStuff")
        .doc(itemId)
        .delete();
  }

  // Delete a household item
  Future<void> deleteHouseItem(String houseId, String itemId) {
    return _firestore
        .collection("House")
        .doc(houseId)
        .collection("HouseItem")
        .doc(itemId)
        .delete();
  }

  // Transfer the item from myStuff to myHouse, the id of the item would be different in HouseItem
  Future<void> transferItemToHouse(
      String myHouseId, String userId, String itemId) async {
    try {
      DocumentSnapshot itemSnapshot = await _firestore
          .collection("Users")
          .doc(userId)
          .collection("MyStuff")
          .doc(itemId)
          .get();

      if (itemSnapshot.exists) {
        DocumentReference houseItemDoc = _firestore
            .collection("House")
            .doc(myHouseId)
            .collection("HouseItem")
            .doc();
        String houseItemId = houseItemDoc.id;

        await _firestore
            .collection("House")
            .doc(myHouseId)
            .collection("HouseItem")
            .doc(houseItemId)
            .set(itemSnapshot.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error when sharing item to household");
    }
  }
}
