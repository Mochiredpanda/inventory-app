import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../FirebaseSettings/firestore_provider.dart';
import 'package:logger/logger.dart';

import 'dart:io';

/// Add Item Page
///
/// A StatefulWidget of Form allows users to input required fields for an Item
/// It includes Name, Price, Brand, mainImages, receipt and other attributes
/// By submission, the form will parse into a JSON object with the current user
/// as the owner and upload to firebase database collection of the owner.

// Initialize the logger for error handling
var logger = Logger();

// Used for diffientiate image and receipt uploads type
enum ImageType { mainImage, receipt }

/// Add Item
///
/// Creates a form with required fields for users to upload an Item object
/// The form is stored in a JSON object and uploaded to Firebase Storage
class AddItemPage extends StatefulWidget {
  const AddItemPage({required this.label, super.key});

  final String label;

  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  // Required input fields controller
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _purchaseDateController = TextEditingController();
  final TextEditingController _addDateController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _methodController = TextEditingController();
  final TextEditingController _purchasedAtController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final db = FirebaseFirestore.instance;
  final firestoreProvider = FirestoreProvider();

  final ImagePicker _picker = ImagePicker();

  // Variables for controlling Image uploads
  XFile? _mainImageFile;
  XFile? _receiptImageFile;
  String? mainImagePath;
  String? receiptImagePath;

  /// Upload an image file to firebase database
  ///
  /// This method uploads a given image file into Firebase directories based
  /// on the user's ID and named with timestamp and its original file name.
  ///
  /// [imageFile] - The image to be uploaded.
  /// [imageType] - Specifies the type of the image is mainImage or Receipt.
  ///
  /// Returns the download URL of the uploaded image if successful,
  ///   otherwise returns null.
  Future<String?> uploadImageFile(XFile? imageFile, ImageType imageType) async {
    // Return null immediately if no file found
    if (imageFile == null) return null;

    // Fetch current userId; if not available, return null
    String? userId = _getCurUserId();
    if (userId == null) {
      return null;
    }

    // Generate reference to firebase storage bucket
    var storageRef = FirebaseStorage.instance.ref();
    // Naming file with user id and time
    String fileName =
        'images/$userId/${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}';
    var curImageRef = storageRef.child(fileName);

    // Attempt to upload and fetch the url
    try {
      await curImageRef.putFile(File(imageFile.path));
      String imageUrl = await curImageRef.getDownloadURL();
      return imageUrl;
    } catch (e) {
      logger.e("Error uploading image: $e");
      return null;
    }
  }

  /// Image Picker
  ///
  /// Method to pick the image from gallery or camera (for mainImage or receipt)
  /// and upload the image to Firebase by calling `uploadImageFile`
  /// then it updates the global variable of the image path and url
  ///
  /// [source] - the source of the image, can be camera or gallery.
  /// [type] - the type of image being picked, can be mainImage or receipt
  ///
  /// Iteration Notes: Current implement does not support web app version
  /// Dependency `image_picker_for_web` needed for web OS for future iteration
  Future<void> _pickImage(ImageSource source, ImageType type) async {
    try {
      // Attempt to pick image from specified source
      final pickedFile = await _picker.pickImage(source: source);
      // When picked, upload it and fetch the url
      if (pickedFile != null) {
        final imageUrl = await uploadImageFile(pickedFile, type);
        setState(() {
          // set global variable based on type of mainImage or receipt
          if (type == ImageType.mainImage) {
            _mainImageFile = pickedFile;
            mainImagePath = imageUrl;
          } else if (type == ImageType.receipt) {
            _receiptImageFile = pickedFile;
            receiptImagePath = imageUrl;
          }
        });
      }
    } catch (e) {
      logger.e("Error picking image: $e");
    }
  }

  /// Display Image at Container
  ///
  /// Helper method used to update the image container for the image preview
  ///
  /// [imageUrl] - the Url of the image to be displayed from the server database
  Widget _displayImage(String? imageUrl) {
    if (imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          width: 150.0,
          height: 150.0,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
                child: Text(
              "Error loading image.",
              semanticsLabel: 'Error loading image',
            ));
          },
        ),
      );
    } else {
      return const Center(
        child: Icon(Icons.image, color: Colors.grey, size: 50.0),
      );
    }
  }

  /// Get User Id
  ///
  /// Helper method to get Current User identifier from firebase
  String? _getCurUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  // Lists for dropdown selection buttons
  String? _selectedPurchaseMethod;
  final List<String> _purchaseMethods = ['In Store', 'Online', 'Gift'];
  String? _selectedItemLocation;
  final List<String> _itemLocations = [
    'Bedroom #1',
    'Bedroom #2',
    'Kitchen',
    'Living Room',
    'Bathroom',
    'Garage',
    'Dining Room'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _brandController.dispose();
    _purchaseDateController.dispose();
    _addDateController.dispose();
    _locationController.dispose();
    _methodController.dispose();
    _purchasedAtController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // initialize the date input fields
  @override
  void initState() {
    super.initState();
    _purchaseDateController.text = DateFormat.yMd().format(DateTime.now());
    _addDateController.text = DateFormat.yMd().format(DateTime.now());
    _selectedPurchaseMethod = _purchaseMethods.first;
    _selectedItemLocation = _itemLocations.first;
  }

  /// Submit form to the server
  ///
  /// Helper method to submit the current form
  /// and generate a JSON object as Item to the server database
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // get the current user as owner
      String? userId = _getCurUserId();
      Map<String, dynamic> userData = await firestoreProvider.fetchUserData();

      // Create JSON object from the form fields
      Map<String, dynamic> itemData = {
        'owner': userId,
        'name': _nameController.text,
        'price': _priceController.text.isNotEmpty
            ? double.parse(_priceController.text).toStringAsFixed(2)
            : null,
        'brand': _brandController.text,
        'purchasedDate': _purchaseDateController.text,
        'dateAdded': _addDateController.text,
        'location': _selectedItemLocation,
        'purchaseMethod': _selectedPurchaseMethod,
        'purchasedAt': _purchasedAtController.text,
        'notes': _notesController.text,
        'image': mainImagePath,
        'receipt': receiptImagePath,
        'ownerFullName': '${userData['FirstName']} ${userData['LastName']}',
      };

      final itemFirestoreData =
          db.collection("Users").doc(userId).collection("MyStuff").doc();
      itemFirestoreData.set(itemData);

      // pop a window to show success adding item
      _showAddedWindow();

      Navigator.of(context).pop();
    }
  }

  /// Popup window of Notice
  ///
  /// Helper method to trigger a popup window to show Item added successfully
  void _showAddedWindow() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Success',
            semanticsLabel: 'Success',
          ),
          content: const Text(
            'Item successfully added.',
            semanticsLabel: 'Item successfully added',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'OK',
                semanticsLabel: 'Ok',
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

  /// Date selector
  ///
  /// Helper method for date selector input fields
  /// Modified for multiple datePickers of PurchasedDate and AddedDate
  void _selectDate(TextEditingController controller) {
    showDatePicker(
      context: context,
      initialDate: controller.text.isNotEmpty
          ? DateFormat.yMd().parse(controller.text)
          : DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        controller.text = DateFormat.yMd().format(pickedDate);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          "ADD ITEM",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
          ),
          semanticsLabel: 'Add item',
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                // Item Name Field (Text)
                TextFormField(
                  controller: _nameController,
                  // This widget is supposed to be larger then the other
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: 'Item Name*',
                    suffixIcon: const Icon(Icons.edit),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5)),
                    filled: true,
                    fillColor: Theme.of(context).primaryColor.withOpacity(0.3),
                    contentPadding: const EdgeInsets.fromLTRB(40, 10, 48, 12),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please provide a name.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Main Image uploads and imagePicker buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    // Thumbnail preview display box
                    Container(
                      width: 150.0,
                      height: 150.0,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _displayImage(mainImagePath),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                    // Image picker buttons
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.photo_camera),
                          onPressed: () => _pickImage(
                              ImageSource.camera, ImageType.mainImage),
                          tooltip: 'Take a picture',
                        ),
                        IconButton(
                          icon: const Icon(Icons.photo_library),
                          onPressed: () => _pickImage(
                              ImageSource.gallery, ImageType.mainImage),
                          tooltip: 'Pick from gallery',
                        ),
                      ],
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                    Expanded(
                      child: Column(
                        children: [
                          // Price & Brand in a Column
                          TextFormField(
                            controller: _priceController,
                            decoration: const InputDecoration(
                              labelText: 'Price \$ *',
                              suffixIcon: Icon(Icons.edit),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: <TextInputFormatter>[
                              // numbers with up to 2 decimal places
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}')),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a price.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          // Item Brand Field (Text)
                          //    Currently implemented as REQUIRED
                          TextFormField(
                            controller: _brandController,
                            decoration: const InputDecoration(
                              labelText: 'Brand*',
                              suffixIcon: Icon(Icons.edit),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter a brand.';
                              }
                              return null;
                            },
                          ),
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
                      child: TextFormField(
                        controller: _purchaseDateController,
                        decoration: const InputDecoration(
                          labelText: 'Purchased Date',
                          suffixIcon: Icon(Icons.calendar_month_rounded),
                        ),
                        readOnly: true,
                        onTap: () => _selectDate(_purchaseDateController),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      // Added Date Field
                      child: TextFormField(
                        controller: _addDateController,
                        decoration: const InputDecoration(
                          labelText: 'Date Added',
                          suffixIcon: Icon(Icons.calendar_month_rounded),
                        ),
                        readOnly: true,
                        onTap: () => _selectDate(_addDateController),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Row 3: Item location and Purchased method
                Row(
                  children: <Widget>[
                    Expanded(
                      // Item Location (Dropdown)
                      child: DropdownButtonFormField(
                        decoration: const InputDecoration(
                          labelText: 'Item Location',
                        ),
                        value: _selectedItemLocation,
                        items: _itemLocations.map((String method) {
                          return DropdownMenuItem(
                              value: method,
                              child: Text(
                                method,
                                semanticsLabel: method,
                              ));
                        }).toList(),
                        onChanged: (String? newLocation) {
                          setState(() {
                            _selectedItemLocation = newLocation;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      // Purchase method dropdown
                      child: DropdownButtonFormField(
                        decoration: const InputDecoration(
                          labelText: 'Purchase Type',
                        ),
                        value: _selectedPurchaseMethod,
                        items: _purchaseMethods.map((String method) {
                          return DropdownMenuItem(
                              value: method,
                              child: Text(
                                method,
                                semanticsLabel: method,
                              ));
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedPurchaseMethod = newValue;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Row 4 Single field of Purchased at
                //    Non-required field
                TextFormField(
                  controller: _purchasedAtController,
                  decoration: const InputDecoration(
                    labelText: 'Purchased At',
                    suffixIcon: Icon(Icons.edit),
                  ),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    return null;
                  },
                ),
                // Row 5 Single field of Notes (larger)
                //    Non-required field
                const SizedBox(height: 20),
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: 'Notes',
                    suffixIcon: const Icon(Icons.edit),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5)),
                    contentPadding: const EdgeInsets.fromLTRB(10, 80, 48, 12),
                  ),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Receipt upload
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    // Thumbnail preview display box
                    Container(
                      width: 150.0,
                      height: 150.0,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _receiptImageFile == null
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Icon for receipt
                                  Icon(Icons.receipt_long,
                                      size: 50.0, color: Colors.grey),
                                  Text(
                                    'Upload Receipt',
                                    style: TextStyle(color: Colors.grey),
                                    semanticsLabel: 'Upload Receipt',
                                  ), // Prompt text
                                ],
                              ),
                            )
                          : _displayImage(receiptImagePath),
                    ),
                    const SizedBox(width: 30),
                    // Image picker buttons
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.photo_camera),
                          onPressed: () =>
                              _pickImage(ImageSource.camera, ImageType.receipt),
                          tooltip: 'Take a picture',
                        ),
                        IconButton(
                          icon: const Icon(Icons.photo_library),
                          onPressed: () => _pickImage(
                              ImageSource.gallery, ImageType.receipt),
                          tooltip: 'Pick from gallery',
                        ),
                      ],
                    ),
                  ],
                ),
                // Form ends here
                // Submit Button
                Container(
                  padding: const EdgeInsets.only(
                      top: 30, left: 35.0, right: 35.0, bottom: 30),
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.black,
                      textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1),
                      fixedSize: const Size(200, 40),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7)),
                    ),
                    onPressed: _submitForm,
                    child: const Text(
                      'Save Item',
                      semanticsLabel: 'Save Item',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
