import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom Navigation Bar Widget
/// 
/// A StatelessWidget bottom navigation bar widget that has consists three main components(pages): MyStuff,
/// MyHouse, and MyProfile. 
/// By clicking on the navigation bar, the user will be navigated to a new page
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    required this.child,
    super.key,
  });

  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Theme.of(context).primaryColor,
        ),
        child: BottomNavigationBar(
          // Three main items within the bottom navigation bar
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory),
              label: 'My Stuff',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'My Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          // Changes on icons and themes when selected
          selectedItemColor: Colors.white,
          selectedIconTheme: const IconThemeData(color: Colors.white, size: 27),
          selectedLabelStyle:
              const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          unselectedItemColor: Colors.black,
          unselectedIconTheme: const IconThemeData(color: Colors.black),
          unselectedLabelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          currentIndex: _selectIndex(context),
          onTap: (int index) => _tapItem(index, context),
        ),
      ),
    );
  }

  /// Setting GoRouterState, get the index of the selected navigation options
  static int _selectIndex(BuildContext context) {
    final String route = GoRouterState.of(context).uri.toString();
    if (route.startsWith('/myStuffPage')) {
      return 0;
    }
    if (route.startsWith('/myHousePage')) {
      return 1;
    }
    if (route.startsWith('/myProfilePage')) {
      return 2;
    }
    return 0;
  }

/// Tapping on the navigation options and navigate to another main page
  void _tapItem(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/myStuffPage');
        break;
      case 1:
        GoRouter.of(context).go('/myHousePage');
        break;
      case 2:
        GoRouter.of(context).go('/myProfilePage');
        break;
    }
  }
}
