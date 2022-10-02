// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import '../../res/app_colors.dart';

class IncrementBtn extends StatelessWidget {
  final int value;
  final Function(int value) onPressed;

  const IncrementBtn({
    super.key,
    required this.value,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    String str = value.toString();
    if (value > 0) {
      str = "+$str";
    }
    return TextButton(
      onPressed: () => onPressed(value),
      child: Text(
        str,
        style: TextStyle(color: AppColors.primary, fontSize: 18),
      ),
    );
  }

//////////////////////////////// WIDGETS ////////////////////////////////

//////////////////////////////// LISTENERS ////////////////////////////////

//////////////////////////////// FUNCTIONS ////////////////////////////////
}
