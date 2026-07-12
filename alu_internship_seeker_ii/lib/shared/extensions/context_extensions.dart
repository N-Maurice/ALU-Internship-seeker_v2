import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';

extension ContextX on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;

  void showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? AppColors.error : AppColors.navy,
        ),
      );
  }
}
