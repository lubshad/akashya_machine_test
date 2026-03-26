import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum AppEnv { dev, prod }

class AppConfig {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static BuildContext? get context => navigatorKey.currentContext;

  static AppEnv env = AppEnv.dev;
  static String geminiApiKey = '';

  static String? devEmail;
  static String? devPassword;
  static String? devPhone;

  static Future<void> init({
    required AppEnv environment,
    String? apiKey,
    String? email,
    String? password,
    String? phone,
  }) async {
    env = environment;
    // Load environment variables
    await dotenv.load(fileName: ".env");
    geminiApiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    devEmail = email;
    devPassword = password;
    devPhone = phone;
  }

  static String get baseUrl =>
      'https://generativelanguage.googleapis.com/v1beta';

  static bool get isDebug => env == AppEnv.dev;
}
