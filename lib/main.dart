import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story/provider/auth_provider.dart';
import 'package:story/provider/story_provider.dart';
import 'package:story/routes/router_delegate.dart';
import 'package:story/routes/router_information_parser.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StoryProvider()),
        ChangeNotifierProvider(
            create: (_) =>
                StoryAppRouterDelegate()), 
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final StoryAppRouterDelegate routerDelegate =
        Provider.of<StoryAppRouterDelegate>(context);
    final StoryAppRouteInformationParser routeInformationParser =
        StoryAppRouteInformationParser();

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerDelegate: routerDelegate,
      routeInformationParser: routeInformationParser,
    );
  }
}
