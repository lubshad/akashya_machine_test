import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastHelper {
  static void show({
    required BuildContext context,
    required String title,
    String? description,
    required ToastificationType type,
  }) {
    toastification.show(
      context: context,
      type: type,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(seconds: 5),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      description: description != null
          ? Text(
              description,
              style: const TextStyle(fontSize: 12),
              maxLines: 5, // Support larger messages as per Rule 10
              overflow: TextOverflow.visible,
            )
          : null,
      alignment: Alignment.topRight,
      direction: TextDirection.ltr,
      animationDuration: const Duration(milliseconds: 300),
      borderRadius: BorderRadius.circular(12),
      showProgressBar: true,
      closeButtonShowType: CloseButtonShowType.always,
      pauseOnHover: true,
      dragToClose: true,
    );
  }

  static void success(BuildContext context, String title, [String? description]) {
    show(
      context: context,
      title: title,
      description: description,
      type: ToastificationType.success,
    );
  }

  static void error(BuildContext context, String title, [String? description]) {
    show(
      context: context,
      title: title,
      description: description,
      type: ToastificationType.error,
    );
  }

  static void info(BuildContext context, String title, [String? description]) {
    show(
      context: context,
      title: title,
      description: description,
      type: ToastificationType.info,
    );
  }
}
