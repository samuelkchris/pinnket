import 'package:flutter/material.dart';
import 'package:flutter_sliding_toast/flutter_sliding_toast.dart';

class ToastManager {
  static final ToastManager _instance = ToastManager._internal();

  factory ToastManager() {
    return _instance;
  }

  ToastManager._internal();

  void showSlideToast(BuildContext context, String text) {
    InteractiveToast.slide(
      context,
      title: Text(text),
      toastStyle: const ToastStyle(titleLeadingGap: 10),
      toastSetting: const SlidingToastSetting(
        animationDuration: Duration(seconds: 1),
        displayDuration: Duration(seconds: 2),
        toastStartPosition: ToastPosition.top,
        toastAlignment: Alignment.topCenter,
      ),
    );
  }

  void showPopToast(BuildContext context, String text) {
    InteractiveToast.pop(
      context,
      title: Text(text),
      toastStyle: const ToastStyle(titleLeadingGap: 10),
      toastSetting: const PopupToastSetting(
        animationDuration: Duration(seconds: 1),
        displayDuration: Duration(seconds: 2),
        toastAlignment: Alignment.topCenter,
      ),
    );
  }

  void showSuccessToast(BuildContext context, String text) {
    InteractiveToast.slideSuccess(
      context,
      title: Text(text, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSecondary)),
      toastStyle: const ToastStyle(titleLeadingGap: 10),
      toastSetting: const SlidingToastSetting(
        maxWidth: 300,
        animationDuration: Duration(seconds: 1),
        displayDuration: Duration(seconds: 2),
        toastStartPosition: ToastPosition.top,
        toastAlignment: Alignment.topCenter,
      ),
    );
  }

  void showErrorToast(BuildContext context, String text) {
    InteractiveToast.slideError(
      context,
      title: Text(text,style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSecondary)),
      toastStyle: const ToastStyle(titleLeadingGap: 10),
      toastSetting: const SlidingToastSetting(
        maxWidth: 300,
        animationDuration: Duration(seconds: 1),
        displayDuration: Duration(seconds: 2),
        toastStartPosition: ToastPosition.top,
        toastAlignment: Alignment.topCenter,
      ),
    );
  }

  void closeAllToasts() {
    InteractiveToast.closeAllToast();
  }

  // Advanced methods for custom configurations
  ToastController customSlideToast(
    BuildContext context, {
    Widget? leading,
    required Widget title,
    Widget? trailing,
    SlidingToastSetting toastSetting = const SlidingToastSetting(
      animationDuration: Duration(seconds: 1),
      displayDuration: Duration(seconds: 2),
      toastStartPosition: ToastPosition.top,
      toastAlignment: Alignment.topCenter,
    ),
    ToastStyle toastStyle = const ToastStyle(),
    Function()? onDisposed,
    Function()? onTapped,
  }) {
    return InteractiveToast.slide(
      context,
      leading: leading,
      title: title,
      trailing: trailing,
      toastSetting: toastSetting,
      toastStyle: toastStyle,
      onDisposed: onDisposed,
      onTapped: onTapped,
    );
  }

  ToastController customPopToast(
    BuildContext context, {
    Widget? leading,
    required Widget title,
    Widget? trailing,
    PopupToastSetting toastSetting = const PopupToastSetting(),
    ToastStyle toastStyle = const ToastStyle(),
    Function()? onDisposed,
    Function()? onTapped,
  }) {
    return InteractiveToast.pop(
      context,
      leading: leading,
      title: title,
      trailing: trailing,
      toastSetting: toastSetting,
      toastStyle: toastStyle,
      onDisposed: onDisposed,
      onTapped: onTapped,
    );
  }

  void showInfoToast(BuildContext context, String s) {
    InteractiveToast.slide(
      context,
      title: Text(s),
      toastStyle: const ToastStyle(titleLeadingGap: 10),
      toastSetting: const SlidingToastSetting(
        animationDuration: Duration(seconds: 1),
        displayDuration: Duration(seconds: 2),
        toastStartPosition: ToastPosition.top,
        toastAlignment: Alignment.topCenter,
      ),
    );
  }
}
