import 'package:flutter/material.dart';

class StoryAppRouteInformationParser
    extends RouteInformationParser<RouteSettings> {
  @override
  Future<RouteSettings> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location);

    if (uri.pathSegments.isEmpty || uri.pathSegments.first == 'login') {
      return const RouteSettings(name: '/login');
    }

    if (uri.pathSegments.first == 'storylist') {
      return const RouteSettings(name: '/storylist');
    }

    return const RouteSettings(name: '/login'); 
  }

  @override
  RouteInformation restoreRouteInformation(RouteSettings configuration) {
    if (configuration.name == '/storylist') {
      return const RouteInformation(location: '/storylist');
    }
    return const RouteInformation(location: '/login');
  }
}
