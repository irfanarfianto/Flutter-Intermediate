import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:story/model/story.dart';
import 'package:story/pages/add_story_page.dart';
import 'package:story/pages/login_page.dart';
import 'package:story/pages/register_page.dart';
import 'package:story/pages/splash_screen.dart';
import 'package:story/pages/story_detail_page.dart';
import 'package:story/pages/story_list_page.dart';
import 'package:story/pages/u.dart';
import 'package:story/routes/page_configuration.dart';

class MyRouterDelegate extends RouterDelegate<PageConfiguration>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  final GlobalKey<NavigatorState> _navigatorKey;

  bool? isLoggedIn;
  bool isUnknown = false;
  bool isRegister = false;
  String? selectedStoryId;
  bool isAddStory = false;

  MyRouterDelegate() : _navigatorKey = GlobalKey<NavigatorState>() {
    _init();
  }

  Future<void> _init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getString('token') != null;
    selectedStoryId = prefs.getString('selectedStoryId');
    notifyListeners();
  }

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  @override
  PageConfiguration? get currentConfiguration {
    if (isLoggedIn == null) {
      return PageConfiguration.splash();
    } else if (isRegister) {
      return PageConfiguration.register();
    } else if (isLoggedIn == false) {
      return PageConfiguration.login();
    } else if (isUnknown) {
      return PageConfiguration.unknown();
    } else if (selectedStoryId == null && !isAddStory) {
      return PageConfiguration.home();
    } else if (selectedStoryId != null) {
      return PageConfiguration.detailStory(selectedStoryId!);
    } else if (isAddStory) {
      return PageConfiguration.addStory();
    } else {
      return null;
    }
  }

  @override
  Future<void> setNewRoutePath(PageConfiguration configuration) async {
    if (configuration.isUnknownPage) {
      isUnknown = true;
      isRegister = false;
      selectedStoryId = null;
      isAddStory = false;
    } else if (configuration.isRegisterPage) {
      isRegister = true;
      selectedStoryId = null;
      isAddStory = false;
    } else if (configuration.isLoginPage || configuration.isSplashPage) {
      isUnknown = false;
      isRegister = false;
      selectedStoryId = null;
      isAddStory = false;
    } else if (configuration.isHomePage) {
      isUnknown = false;
      isRegister = false;
      selectedStoryId = null;
      isAddStory = false;
    } else if (configuration.isDetailStoryPage &&
        configuration.storyId != null) {
      isUnknown = false;
      isRegister = false;
      selectedStoryId = configuration.storyId;
      isAddStory = false;
    } else if (configuration.isAddStoryPage) {
      isUnknown = false;
      isRegister = false;
      selectedStoryId = null;
      isAddStory = true;
    }

    notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    List<Page> historyStack = [];

    if (isUnknown) {
      historyStack = _unknownStack;
    } else if (isLoggedIn == null) {
      historyStack = _splashStack;
    } else if (isLoggedIn == false) {
      historyStack = _loggedOutStack;
    } else if (isLoggedIn == true && selectedStoryId == null && !isAddStory) {
      historyStack = _loggedInStack;
    } else if (isLoggedIn == true && selectedStoryId != null) {
      historyStack = _storyDetailStack(selectedStoryId!);
    } else if (isAddStory) {
      historyStack = _addStoryStack();
    }

    return Navigator(
      key: navigatorKey,
      pages: historyStack,
      onPopPage: (route, result) {
        final didPop = route.didPop(result);
        if (!didPop) {
          return false;
        }

        if (isRegister) {
          isRegister = false;
        }
        // saya rasa sudah menerapkannya sesuai dengan
        // yang ada di learning path nya, tapi saat dicoba malah tidak berhasil terus
        selectedStoryId = null;
        isAddStory = false;

        notifyListeners();

        return true;
      },
    );
  }

  List<Page> get _unknownStack {
    return [
      const MaterialPage(
        key: ValueKey('UnknownPage'),
        child: UnknownScreen(),
      ),
    ];
  }

  List<Page> get _splashStack {
    return [
      const MaterialPage(
        key: ValueKey('SplashScreen'),
        child: SplashScreen(),
      ),
    ];
  }

  List<Page> get _loggedOutStack {
    List<Page> stack = [
      MaterialPage(
        key: const ValueKey("LoginPage"),
        child: LoginPage(
          onLogin: () {
            isLoggedIn = true;
            notifyListeners();
          },
          onRegister: () {
            isRegister = true;
            notifyListeners();
          },
        ),
      ),
    ];

    if (isRegister == true) {
      stack.add(MaterialPage(
        key: const ValueKey("RegisterPage"),
        child: RegisterPage(
          onRegister: () {
            isRegister = false;
            notifyListeners();
          },
          onLogin: () {
            isRegister = false;
            notifyListeners();
          },
        ),
      ));
    }

    return stack;
  }

  List<Page> get _loggedInStack {
    List<Page> stack = [];

    if (isLoggedIn == true) {
      stack.add(
        MaterialPage(
          key: const ValueKey('StoryListPage'),
          child: StoryListPage(
            onLogout: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('token');
              isLoggedIn = false;
              notifyListeners();
            },
            onStorySelected: (Story story) {
              selectedStoryId = jsonEncode(story.toJson());
              notifyListeners();
            },
            onAddStory: () {
              isAddStory = true;
              notifyListeners();
            },
          ),
        ),
      );

      if (selectedStoryId != null && _isValidJson(selectedStoryId!)) {
        stack.addAll(_storyDetailStack(selectedStoryId!));
      }
    }

    return stack;
  }

  List<Page> _storyDetailStack(String storyId) {
    Story selectedStory = Story.fromJson(jsonDecode(storyId));

    return [
      MaterialPage(
        key: ValueKey('StoryDetailPage-${selectedStory.id}'),
        child: StoryDetailPage(
          story: selectedStory,
          onBack: () {
            selectedStoryId = null;
            notifyListeners();
          },
        ),
      ),
    ];
  }

  List<Page> _addStoryStack() {
    return [
      MaterialPage(
        key: const ValueKey('AddStoryPage'),
        child: AddStoryPage(
          onStoryAdded: () {
            isAddStory = false;
            notifyListeners();
          },
          onBack: () {
            isAddStory = false;
            notifyListeners();
          },
        ),
      ),
    ];
  }

  bool _isValidJson(String jsonString) {
    try {
      jsonDecode(jsonString);
      return true;
    } catch (_) {
      return false;
    }
  }
}
