import 'package:flutter/material.dart';

import '../../res/app_colors.dart';

class LoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top:16),
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}
