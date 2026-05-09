import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RouteConfig {
  final String path;
  final String title;
  final WidgetBuilder builder;

  const RouteConfig({
    required this.path,
    required this.title,
    required this.builder,
  });
}

const routeConfigs = <String, RouteConfig>{
  'events': RouteConfig(
    path: '/events',
    title: '事件目录',
    builder: _buildEventsScreen,
  ),
  'contract': RouteConfig(
    path: '/contract/:eventId',
    title: '契约管理',
    builder: _buildContractScreen,
  ),
  'workflows': RouteConfig(
    path: '/workflows',
    title: '流程编排',
    builder: _buildWorkflowsScreen,
  ),
};

Widget _buildEventsScreen(BuildContext context) {
  throw UnimplementedError('Inject via BlocProvider');
}

Widget _buildContractScreen(BuildContext context) {
  throw UnimplementedError('Inject via BlocProvider');
}

Widget _buildWorkflowsScreen(BuildContext context) {
  throw UnimplementedError('Inject via BlocProvider');
}

class AppRouter {
  static GoRouter create() {
    return GoRouter(
      initialLocation: '/events',
      routes: [
        GoRoute(
          path: '/',
          redirect: (context, state) => '/events',
        ),
        GoRoute(
          path: '/events',
          builder: (context, state) => routeConfigs['events']!.builder(context),
        ),
        GoRoute(
          path: '/contract/:eventId',
          builder: (context, state) => routeConfigs['contract']!.builder(context),
        ),
        GoRoute(
          path: '/workflows',
          builder: (context, state) => routeConfigs['workflows']!.builder(context),
        ),
      ],
    );
  }
}
