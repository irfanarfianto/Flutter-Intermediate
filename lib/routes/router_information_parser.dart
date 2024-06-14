// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:story/routes/page_configuration.dart';

class MyRouteInformationParser
    extends RouteInformationParser<PageConfiguration> {
  @override
  Future<PageConfiguration> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location);

    if (uri.pathSegments.isEmpty) {
      return PageConfiguration.home();
    } else if (uri.pathSegments.length == 1) {
      final first = uri.pathSegments[0].toLowerCase();
      if (first == 'home') {
        return PageConfiguration.home();
      } else if (first == 'login') {
        return PageConfiguration.login();
      } else if (first == 'register') {
        return PageConfiguration.register();
      } else if (first == 'splash') {
        return PageConfiguration.splash();
      } else if (first == 'addstory') {
        return PageConfiguration.addStory();
      } else {
        return PageConfiguration.unknown();
      }
    } else if (uri.pathSegments.length == 2) {
      final first = uri.pathSegments[0].toLowerCase();
      final second = uri.pathSegments[1];
      if (first == 'story') {
        return PageConfiguration.detailStory(second);
      } else {
        return PageConfiguration.unknown();
      }
    } else {
      return PageConfiguration.unknown();
    }
  }

  @override
  RouteInformation restoreRouteInformation(PageConfiguration configuration) {
    if (configuration.isUnknownPage) {
      return const RouteInformation(location: '/unknown');
    } else if (configuration.isSplashPage) {
      return const RouteInformation(location: '/splash');
    } else if (configuration.isRegisterPage) {
      return const RouteInformation(location: '/register');
    } else if (configuration.isLoginPage) {
      return const RouteInformation(location: '/login');
    } else if (configuration.isHomePage) {
      return const RouteInformation(location: '/');
    } else if (configuration.isAddStoryPage) {
      return const RouteInformation(location: '/addstory');
    } else if (configuration.isDetailStoryPage &&
        configuration.storyId != null) {
      return RouteInformation(location: '/story/${configuration.storyId}');
    } else {
      return const RouteInformation(location: '/unknown');
    }
  }
}
