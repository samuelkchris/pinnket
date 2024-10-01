import 'dart:ui';

import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pinnket/providers/event_provider.dart';
import 'package:pinnket/providers/footer_provider.dart';
import 'package:pinnket/providers/selectedevent_provider.dart';
import 'package:pinnket/providers/selectedzone_provider.dart';
import 'package:pinnket/providers/theme_provider.dart';
import 'package:pinnket/providers/user_provider.dart';
import 'package:pinnket/routes/routes.dart';
import 'package:pinnket/services/firebase_service.dart';
import 'package:pinnket/services/registry_service.dart';
import 'package:provider/provider.dart';
import 'package:wiredash/wiredash.dart';
import 'package:yaru/theme.dart';
import 'package:hive/hive.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Registries.registerRedDivFactory();
  Hive.init('pinnket');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SelectedEventProvider()),
        ChangeNotifierProvider(create: (_) => TicketSelectionProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => FooterStateModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Wiredash(
        projectId: 'pinnket-hvh40z3',
        secret: 'Vqt1kIQREv-CAIcgh-gWphtDudzWODRt',
        feedbackOptions: const WiredashFeedbackOptions(
          labels: [
            Label(id: 'label-h8qxt6x2md', title: 'Bug'),
            Label(id: 'label-j7bbzyvuab', title: 'Improvement'),
            Label(id: 'label-1kzt2953bw', title: 'Payment'),
            Label(id: 'label-nogzhb6hfk', title: 'Praise'),
            Label(id: 'label-ej6x8wyu92', title: 'Others'),
          ],
        ),
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'PinnKET',
          routerConfig: goRouter,
          highContrastTheme: yaruHighContrastLight,
          highContrastDarkTheme: yaruHighContrastDark,
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.themeMode,

          scrollBehavior: const MaterialScrollBehavior().copyWith(
            dragDevices: {
              PointerDeviceKind.mouse,
              PointerDeviceKind.touch,
              PointerDeviceKind.stylus,
              PointerDeviceKind.unknown,
              PointerDeviceKind.trackpad,
            },
          ),
        ));
  }
}
