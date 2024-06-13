import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story/pages/add_story_page.dart';
import 'package:story/pages/login_page.dart';
import 'package:story/pages/register_page.dart';
import 'package:story/pages/story_list_page.dart';
import 'package:story/provider/auth_provider.dart';

class StoryAppRouterDelegate extends RouterDelegate<RouteSettings>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteSettings> {
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  StoryAppRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>() {
    // Initialize selectedRoute to a default route
    selectedRoute = const RouteSettings(name: '/login');
  }

  RouteSettings? selectedRoute;

  @override
  RouteSettings? get currentConfiguration => selectedRoute;

  void navigateToLogin() {
    selectedRoute = const RouteSettings(name: '/login');
    notifyListeners();
  }

  void navigateToRegister() {
    selectedRoute = const RouteSettings(name: '/register');
    notifyListeners();
  }

  void navigateToStoryList() {
    selectedRoute = const RouteSettings(name: '/storylist');
    notifyListeners();
  }

  void navigateToAddStory() {
    selectedRoute = const RouteSettings(name: '/addstory');
    notifyListeners();
  }

  void navigateToStoryDetail(Map<String, dynamic> story) {
    selectedRoute = RouteSettings(
      name: '/storydetail',
      arguments: {
        'id': story['id'],
        'photoUrl': story['photoUrl'],
        'name': story['name'],
        'description': story['description'],
        'creationTime': story['createdAt'],
      },
    );
    notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    if (selectedRoute == null) {
      return Container();
    }

    return Navigator(
      key: navigatorKey,
      pages: [
        if (selectedRoute!.name == '/login')
          const MaterialPage(
            key: ValueKey('LoginPage'),
            child: LoginPage(),
          ),
        if (selectedRoute!.name == '/register')
          const MaterialPage(
            key: ValueKey('RegisterPage'),
            child: RegisterPage(),
          ),
        if (selectedRoute!.name == '/storylist')
          const MaterialPage(
            key: ValueKey('StoryListPage'),
            child: StoryListPage(),
          ),
        if (selectedRoute!.name == '/addstory')
          const MaterialPage(
            key: ValueKey('AddStoryPage'),
            child: AddStoryPage(),
          ),
      ],
      onPopPage: (route, result) {
        return route.didPop(result);
      },
    );
  }

  @override
  Future<void> setInitialRoutePath(RouteSettings configuration) async {
    final authProvider =
        Provider.of<AuthProvider>(navigatorKey.currentContext!, listen: false);

    if (authProvider.token != null) {
      selectedRoute = const RouteSettings(name: '/storylist');
    } else {
      selectedRoute = const RouteSettings(name: '/login');
    }

    notifyListeners();
  }

  @override
  Future<void> setNewRoutePath(RouteSettings configuration) async {
    final authProvider =
        Provider.of<AuthProvider>(navigatorKey.currentContext!, listen: false);

    if (authProvider.token != null) {
      selectedRoute = const RouteSettings(name: '/storylist');
    } else {
      selectedRoute = const RouteSettings(name: '/login');
    }

    notifyListeners();
  }
}
