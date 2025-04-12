import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory/Pages/edit_item_page.dart';
import 'package:inventory/Pages/edit_profile_page.dart';
import './my_stuff_page.dart';
import './my_house_page.dart';
import './my_profile_page.dart';
import './add_item_page.dart';
import './invite_member_page.dart';
import './about_page.dart';
import './my_profile_feedback_and_support_page.dart';
import '../Components/bottom_nav_bar.dart';
import 'item_detail_page.dart';
import './create_household_page.dart';
import './house_item_detail_page.dart';
import './scan_to_join_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');
const Color themeColor = Color(0xff12CDD4);

/// TempHomePage
///
/// A StatelessWidget that build the three main embedded pages- MyStuff, MyHouse, and MyProfile.
/// Set up GoRouter/ShellRouter for navigation. And to have bottom navigation bar displayed on every pages,
/// and every new pages pushed on to them
class TempHomePage extends StatelessWidget {
  TempHomePage({
    super.key,
  });

  final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/myStuffPage',
    debugLogDiagnostics: true,
    routes: <RouteBase>[
      /// Application shell
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return BottomNavBar(child: child);
        },
        routes: <RouteBase>[
          /// The first screen to display in the bottom navigation bar.
          GoRoute(
            path: '/myStuffPage',
            builder: (BuildContext context, GoRouterState state) {
              return const MyStuffPage();
            },
            routes: <RouteBase>[
              // The details screen to display stacked on the inner Navigator.
              GoRoute(
                path: 'addItem',
                builder: (BuildContext context, GoRouterState state) {
                  return const AddItemPage(label: 'addItem');
                },
              ),
              // The item detail page, itemId would be passed to url
              GoRoute(
                path: 'individualItem/:userId/:itemId',
                builder: (BuildContext context, GoRouterState state) {
                  final Map<String, String> params = state.pathParameters;
                  final userId = params['userId'] ?? '';
                  final itemId = params['itemId'] ?? '';
                  return ItemDetailPage(userId: userId, itemId: itemId);
                },
              ),
              // The edit item page, itemId would be passed to url
              GoRoute(
                path: 'editItem/:userId/:itemId',
                builder: (BuildContext context, GoRouterState state) {
                  final Map<String, String> params = state.pathParameters;
                  final userId = params['userId'] ?? '';
                  final itemId = params['itemId'] ?? '';
                  return EditItemPage(userId: userId, itemId: itemId);
                },
              )
            ],
          ),

          /// Displayed when the second item in the the bottom navigation bar is
          /// selected.
          GoRoute(
            path: '/myHousePage',
            builder: (BuildContext context, GoRouterState state) {
              return const MyHousePage();
            },
            routes: <RouteBase>[
              // The details screen to display stacked on the inner Navigator.
              GoRoute(
                path: 'inviteMemberPage',
                builder: (BuildContext context, GoRouterState state) {
                  return const InviteMemberPage();
                },
              ),
              GoRoute(
                path: 'createHouseholdPage',
                builder: (BuildContext context, GoRouterState state) {
                  return const CreateHouseholdPage();
                },
              ),
              // Scan to join household
              GoRoute(
                path: 'joinHouseholdPage',
                builder: (BuildContext context, GoRouterState state) {
                  return ScanToJoinPage();
                },
              ),
              GoRoute(
                path: 'individualHouseItem/:houseId/:itemId',
                builder: (BuildContext context, GoRouterState state) {
                  final Map<String, String> params = state.pathParameters;
                  final houseId = params['houseId'] ?? '';
                  final itemId = params['itemId'] ?? '';
                  return HouseItemDetailPage(houseId: houseId, itemId: itemId);
                },
              ),
            ],
          ),

          /// The third screen to display in the bottom navigation bar.
          GoRoute(
            path: '/myProfilePage',
            builder: (BuildContext context, GoRouterState state) {
              return const MyProfilePage();
            },
            routes: <RouteBase>[
              // The details screen to display stacked on the inner Navigator.
              // This will cover screen A but not the application shell.
              GoRoute(
                path: 'editProfile',
                builder: (BuildContext context, GoRouterState state) {
                  return const EditProfilePage();
                },
              ),
              GoRoute(
                path: 'about',
                builder: (BuildContext context, GoRouterState state) {
                  return const AboutPage();
                },
              ),
              GoRoute(
                  path: 'support',
                  builder: (BuildContext context, GoRouterState state) {
                    return const SupportPage();
                  }),
            ],
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Avenger',
      theme: ThemeData(
        primaryColor: themeColor,
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}
