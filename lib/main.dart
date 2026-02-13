import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/api_client.dart';
import 'providers/api_provider.dart';
import 'screens/ip_entry_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_event_screen.dart';
import 'screens/trace_screen.dart';
import 'screens/trace_root_screen.dart';

void main() {
  runApp(const TraceletApp());
}

class TraceletApp extends StatelessWidget {
  const TraceletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ApiProvider(),
      child: Consumer<ApiProvider>(
        builder: (context, apiProv, _) => MaterialApp(
          title: 'Tracelet',
          theme: ThemeData.dark().copyWith(
            useMaterial3: true,
            appBarTheme: const AppBarTheme(centerTitle: true),
          ),
          home: const RootRouter(),
          onGenerateRoute: (settings) {
            final args = settings.arguments;
            final client = apiProv.client;

            if (client == null) {
              return _errorRoute("API client not initialized");
            }

            switch (settings.name) {
              case "/add_event":
                if (args is Map<String, dynamic> && args.containsKey("trackingNumber")) {
                  return MaterialPageRoute(
                    builder: (_) => AddEventScreen(
                      apiClient: client,
                      trackingNumber: args["trackingNumber"],
                    ),
                  );
                }
                return _errorRoute("Missing trackingNumber for AddEventScreen");

              case "/trace":
                if (args is Map<String, dynamic> && args.containsKey("trackingNumber")) {
                  return MaterialPageRoute(
                    builder: (_) => TraceScreen(
                      apiClient: client,
                      trackingNumber: args["trackingNumber"],
                    ),
                  );
                }
                return _errorRoute("Missing trackingNumber for TraceScreen");

              case "/trace_root":
                if (args is Map<String, dynamic> && args.containsKey("rootId")) {
                  return MaterialPageRoute(
                    builder: (_) => TraceRootScreen(
                      apiClient: client,
                      rootId: args["rootId"],
                    ),
                  );
                }
                return _errorRoute("Missing rootId for TraceRootScreen");

              default:
                return null;
            }
          },
        ),
      ),
    );
  }

  MaterialPageRoute _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: Center(child: Text(message)),
      ),
    );
  }
}

class RootRouter extends StatelessWidget {
  const RootRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final apiProv = Provider.of<ApiProvider>(context, listen: true);

    return FutureBuilder<bool>(
      future: apiProv.ensureLoaded(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (apiProv.baseUrl == null || apiProv.baseUrl!.isEmpty) {
          return const IpEntryScreen();
        }

        final client = apiProv.client;
        if (client == null) {
          return Scaffold(
            body: Center(child: Text("API client failed to initialize")),
          );
        }

        // Main screen: Dashboard
        return DashboardScreen(apiClient: client);
      },
    );
  }
}
