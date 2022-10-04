// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import '../../res/app_colors.dart';

class ToggleSpeedBtns extends StatelessWidget {
  final double currentSpeed;
  final Function(double speed) onChanged;

  ToggleSpeedBtns({
    super.key,
    required this.currentSpeed,
    required this.onChanged,
  });

  final List<double> _speeds = <double>[
    1,
    1.25,
    1.5,
    1.75,
    2,
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        ..._speeds.map((double e) => _getItem(e)),
      ],
    );
  }

//////////////////////////////// WIDGETS ////////////////////////////////

  Widget _getItem(double value) => InkWell(
        onTap: () => onChanged(value),
        child: DecoratedBox(
          decoration: value == currentSpeed
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.primary,
                )
              : const BoxDecoration(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
            child: Text(
              "x$value",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: value == currentSpeed ? 16 : 14,
              ),
            ),
          ),
        ),
      );

//////////////////////////////// LISTENERS ////////////////////////////////

//////////////////////////////// FUNCTIONS ////////////////////////////////
}
