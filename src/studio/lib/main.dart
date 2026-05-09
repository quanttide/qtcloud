import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/event_catalog_cubit.dart';
import 'blocs/contract_cubit.dart';
import 'blocs/workflow_cubit.dart';
import 'screens/event_catalog_screen.dart';
import 'screens/contract_screen.dart';
import 'screens/workflow_screen.dart';
import 'theme.dart';

void main() {
  runApp(const QtCloudStudioApp());
}

class QtCloudStudioApp extends StatelessWidget {
  const QtCloudStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => EventCatalogCubit(eventsPath: 'assets/events.json'),
        ),
        BlocProvider(
          create: (_) => ContractCubit(contractsPath: 'assets/contracts.json'),
        ),
        BlocProvider(
          create: (_) => WorkflowCubit(workflowsPath: 'assets/workflows.json'),
        ),
      ],
      child: MaterialApp(
        title: '量潮云协作目录',
        theme: AppTheme.lightTheme,
        initialRoute: '/events',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/events':
              return MaterialPageRoute(
                builder: (_) => const EventCatalogScreen(),
              );
            case '/contract':
              final eventId = settings.arguments as String? ?? '';
              return MaterialPageRoute(
                builder: (_) => ContractScreen(eventId: eventId),
              );
            case '/workflows':
              return MaterialPageRoute(
                builder: (_) => const WorkflowScreen(),
              );
            default:
              return MaterialPageRoute(
                builder: (_) => const EventCatalogScreen(),
              );
          }
        },
      ),
    );
  }
}
