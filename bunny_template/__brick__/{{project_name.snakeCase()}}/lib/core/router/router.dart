import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  /// The route configuration.
  static final GoRouter _router = GoRouter(
      initialLocation: '/',
      navigatorKey: _rootNavigatorKey,
      redirect: (context, state) async {
        return null;
      },
      debugLogDiagnostics: true,
      observers: [
        NavigatorObserver(),
      ],
      routes: routers);

  static GoRouter get router => _router;
}

List<RouteBase> get routers {
  return [];
}
