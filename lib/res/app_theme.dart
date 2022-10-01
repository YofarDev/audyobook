import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData appThemeData = ThemeData(
    scaffoldBackgroundColor: AppColors.bg,
    unselectedWidgetColor: Colors.grey,
    primaryColor: AppColors.primary,

    floatingActionButtonTheme:
        FloatingActionButtonThemeData(backgroundColor: AppColors.primary),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.bg,
      iconTheme: const IconThemeData(color: Colors.white),
    ),
  );
}
