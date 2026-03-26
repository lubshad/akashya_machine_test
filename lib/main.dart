import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'core/theme.dart';
import 'core/router.dart';
import 'firebase_options.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/onboarding/bloc/auth_bloc.dart';
import 'core/services/auth_service.dart';

Future<void> startApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(authService: AuthService())),
      ],
      child: const FinvesteaApp(),
    ),
  );
}

class FinvesteaApp extends StatefulWidget {
  const FinvesteaApp({super.key});

  @override
  State<FinvesteaApp> createState() => _FinvesteaAppState();
}

class _FinvesteaAppState extends State<FinvesteaApp> {
  late final GoRouter appRouter;

  @override
  void initState() {
    super.initState();
    appRouter = createRouter();
  }

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MaterialApp.router(
        title: 'Finvestea',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: appRouter,
      ),
    );
  }
}
