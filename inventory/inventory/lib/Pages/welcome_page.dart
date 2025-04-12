import 'package:flutter/material.dart';
import './create_account_page.dart';
import './change_password_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// WelcomePage
///
/// A StatefulWidget that would display the title of the app, welcome messages,
/// loging or create account options when user first opens the app
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<WelcomePage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _loginErrorMessage = false;

  /// User may log in with their email and password
  void signUserIn() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _loginErrorMessage = true;
      });
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        toolbarHeight: 130,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('images/Logo 1.png', fit: BoxFit.cover, height: 90),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Center(
                  child: Text(
                    'Welcome to Inventory',
                    style: TextStyle(
                        color: Colors.black,
                        // height: 1.2,
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2),
                    semanticsLabel: 'Welcome to Inventory',
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Center(
                child: Text(
                  'Streamline Your Home. Simplify Your Life.',
                  style: TextStyle(
                      color: Colors.black,
                      height: 0.5,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      fontStyle: FontStyle.italic),
                  semanticsLabel: 'Streamline Your Home. Simplify Your Life',
                ),
              ),
              _welcomePageBlackText("Returning user?"),
              _welcomePageInputBox("Email", emailController),
              _welcomePageInputBox("Password", passwordController,
                  hiddenText: true),
              if (_loginErrorMessage) _logInErrorMessage(),
              _welcomePageBlueTextButton(
                  "Forgot email or password?", const ChangePasswordPage()),
              _welcomePageButton('LOGIN', 10.0, 15, 20,
                  Theme.of(context).primaryColor, Colors.black),
              _welcomePageBlackText("New user?"),
              _welcomePageButton(
                  'Create Account', 0, 5, 16, Colors.black, Colors.white,
                  logIn: false),
              _welcomePageBlueTextButton("Privacy", const ChangePasswordPage()),
            ],
          ),
        ),
      ),
    );
  }

  /// Input boxes for user to log in
  ///
  /// [text] - the title of the input box
  /// [controller] - input box controller to store input
  /// [hiddenText] - hide the password text
  Widget _welcomePageInputBox(String text, controller,
      {bool hiddenText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 35, top: 5, bottom: 5),
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
          padding: const EdgeInsets.only(left: 35, right: 35, bottom: 5),
          child: TextFormField(
            controller: controller,
            obscureText: hiddenText,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              hintText: text,
              hintStyle: const TextStyle(fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }

  /// Variety of buttons that appeared on welcome page
  ///
  /// [buttonText] - the button's text
  /// [topPadding] - button's top padding
  /// [bottomPadding] - button's buttom Padding
  /// [fontSize] - font size of the button
  /// [buttonColor] - color of the button
  /// [buttonTextColor] - color of the button's text
  /// [logIn] - distinguish between login or createAccount button (they both shared this method)
  Widget _welcomePageButton(
      String buttonText,
      double topPadding,
      double bottomPadding,
      double fontSize,
      Color buttonColor,
      Color buttonTextColor,
      {bool logIn = true}) {
    return Container(
      padding: EdgeInsets.only(
          top: topPadding, left: 35.0, right: 35.0, bottom: bottomPadding),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: buttonTextColor,
          textStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              letterSpacing: 1),
          fixedSize: const Size(200, 40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        ),
        onPressed: logIn
            ? signUserIn
            : () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return const CreateAccountPage();
                    },
                  ),
                );
              },
        child: Text(
          buttonText,
          semanticsLabel: buttonText,
        ),
      ),
    );
  }

  /// Rendered black text that display basic information
  ///
  /// [blackText] - the black text to display
  Widget _welcomePageBlackText(String blackText) {
    return Padding(
      padding: const EdgeInsets.only(left: 35, top: 15),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          blackText,
          style: const TextStyle(
            color: Colors.black,
            height: 1,
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
          semanticsLabel: blackText,
        ),
      ),
    );
  }

  /// Text button for privacy or forgot email/password
  ///
  /// [blueText] - the blue text to display
  /// [navPageName] - the name of the page navigator will navigate to when click
  /// on the blue text
  Widget _welcomePageBlueTextButton(String blueText, Widget navPageName) {
    return Padding(
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
          child: Text(
            blueText,
            semanticsLabel: blueText,
          ),
        ),
      ),
    );
  }

  ///Red warning text if user has errors when loging in
  Widget _logInErrorMessage() {
    return const Padding(
      padding: EdgeInsets.only(left: 37, top: 5),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Error! Please enter valid email and password!",
          style: TextStyle(
            color: Colors.red,
            height: 1,
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
          semanticsLabel: 'Error! Please enter valid email and password',
        ),
      ),
    );
  }
}
