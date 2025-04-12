import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// CreateAccountPage
///
/// A StatefulWidget allows users to create an account.
/// Users are required to enter their email, password, first name, and last name.
/// Error would be thrown if any input boxes is missing, password is incorrect, repeated
/// email etc. Once user successfully enter correct information, data would be stored in
/// database, and will auto log the user in.
class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<CreateAccountPage> {
  final db = FirebaseFirestore.instance;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _missingFirstName = false;
  bool _missingLastName = false;
  bool _missingEmail = false;
  bool _missingPassword = false;
  bool _missingConfirmPassword = false;

  bool _hasErrorCode = false;
  bool _confirmPasswordNotMatched = false;
  String _errorCode = "";

  /// Set the giving values true if the input boxes are empty, used for _missingInfo
  void _checkInfo() {
    setState(() {
      _missingFirstName = _firstNameController.text == "";
      _missingLastName = _lastNameController.text == "";
      _missingEmail = _emailController.text == "";
      _missingPassword = _passwordController.text == "";
      _missingConfirmPassword = _confirmPasswordController.text == "";
    });
  }

  /// Boolean to see if there is any input boxes left empty
  bool _missingInfo() {
    return _missingFirstName ||
        _missingLastName ||
        _missingEmail ||
        _missingPassword ||
        _missingConfirmPassword;
  }

  /// Create user account in Firestore, error handling when exceptions are thrown
  Future<User?> createAccountAndGetUser() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _emailController.text, password: _passwordController.text);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      String temp = e.code;
      debugPrint(temp);
      if (temp == "email-already-in-use") {
        setState(() {
          _errorCode = "Email already in-use!";
          _hasErrorCode = true;
        });
      } else if (temp == "weak-password") {
        setState(() {
          _errorCode = "Password must be longer than 6 characters!";
          _hasErrorCode = true;
        });
      } else if (temp == "invalid-email") {
        setState(() {
          _errorCode = "Not a valid email!";
          _hasErrorCode = true;
        });
      }
      if (mounted) {
        Navigator.pop(context);
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          "CREATE ACCOUNT",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
          ),
          semanticsLabel: 'Create account',
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
        child: Form(
          child: Column(
            children: [
              _personalInfoInputBox(
                  "First name", "Jane", _firstNameController, 'myKey1'),
              if (_missingFirstName) _missingInputWarning("First Name"),
              _personalInfoInputBox(
                  "Last name", "Doe", _lastNameController, 'myKey2'),
              if (_missingLastName) _missingInputWarning("Last Name"),
              _personalInfoInputBox(
                  "Email", "xyz@email.com", _emailController, 'myKey3'),
              if (_missingEmail) _missingInputWarning("Email"),
              if (_hasErrorCode) _logInErrorMessage(_errorCode),
              _personalInfoInputBox(
                  "Password", "Your password", _passwordController, 'myKey4',
                  hiddenText: true),
              if (_missingPassword) _missingInputWarning("Password"),
              _personalInfoInputBox("Confirm Password", "Repeat your password",
                  _confirmPasswordController, 'myKey5',
                  hiddenText: true),
              if (_confirmPasswordNotMatched) _logInErrorMessage(_errorCode),
              if (_missingConfirmPassword)
                _missingInputWarning("Confirm Password"),
              const Padding(
                padding: EdgeInsets.only(left: 35, top: 50),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '*Required Field',
                    style: TextStyle(
                      color: Colors.black,
                      height: 1,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                    semanticsLabel: 'Required Field',
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(
                    top: 10.0, left: 35.0, right: 35.0, bottom: 5.0),
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1),
                    fixedSize: const Size(200, 40),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7)),
                  ),
                  // Once user click submit, the input boxes would be checked to make sure no
                  // missing information. The data would be stored to firestore database
                  onPressed: () async {
                    _checkInfo();
                    if (!_missingInfo()) {
                      if (_passwordController.text !=
                          _confirmPasswordController.text) {
                        setState(() {
                          _confirmPasswordNotMatched = true;
                          _errorCode = "Password not match";
                        });
                      } else {
                        try {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          );
                          User? user = await createAccountAndGetUser();
                          if (user != null) {
                            final data = <String, String>{
                              "FirstName": _firstNameController.text,
                              "LastName": _lastNameController.text,
                              "Password": _passwordController.text,
                              "Email": _emailController.text,
                            };
                            await db
                                .collection("Users")
                                .doc(user.uid)
                                .set(data);
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                          }
                        } catch (e) {
                          debugPrint("Error $e");
                        }
                      }
                    }
                  },
                  child: const Text(
                    "Create Account",
                    semanticsLabel: 'Create account',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    onPressed: () {},
                    child: const Text(
                      "Privacy",
                      semanticsLabel: 'Privacy',
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// Input Box widget to store user's information
  ///
  /// [text] - title of the input box
  /// [placeholder] - placeholder within the input box
  /// [controller] - input controller
  /// [keyString] - widget key
  /// [hiddenText] - used for password and confirm password, to hide the text
  Widget _personalInfoInputBox(
      String text, String placeholder, controller, String keyString,
      {bool hiddenText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 35, top: 15),
          child: Text(
            '$text*',
            style: const TextStyle(
              color: Colors.grey,
              height: 1.5,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
            semanticsLabel: text,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 35, right: 35),
          child: SizedBox(
            height: 35,
            child: TextFormField(
              key: Key(keyString),
              controller: controller,
              obscureText: hiddenText,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.only(left: 10, right: 10),
                hintText: placeholder,
                hintStyle: const TextStyle(fontSize: 13),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Provide red text warning message when input box is empty
  ///
  /// [text] - the title of the input box that is empty
  Widget _missingInputWarning(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 35),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '$text can not be empty',
          style: const TextStyle(
            color: Colors.red,
            height: 1.5,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
          semanticsLabel: '$text can not be empty',
        ),
      ),
    );
  }

  /// Provide red message text when there is an error when creating account
  ///
  /// [errorCode] - String of errorCode when error is thrown
  Widget _logInErrorMessage(String errorCode) {
    return Padding(
      padding: const EdgeInsets.only(left: 35),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Error! $errorCode',
          style: const TextStyle(
            color: Colors.red,
            height: 1.5,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
          semanticsLabel: 'Error! $errorCode',
        ),
      ),
    );
  }
}
