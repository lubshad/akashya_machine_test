import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastHelper {
  static void showSuccess(BuildContext context, {required String message, String? title}) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.flatColored,
      title: Text(title ?? 'Success'),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 4),
      alignment: Alignment.topRight,
    );
  }

  static void showError(BuildContext context, {required String message, String? title}) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.flatColored,
      title: Text(title ?? 'Error'),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 5),
      alignment: Alignment.topRight,
    );
  }

  static void showInfo(BuildContext context, {required String message, String? title}) {
    toastification.show(
      context: context,
      type: ToastificationType.info,
      style: ToastificationStyle.flatColored,
      title: Text(title ?? 'Info'),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 4),
      alignment: Alignment.topRight,
    );
  }
}
