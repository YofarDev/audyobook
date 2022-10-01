// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import '../../res/app_colors.dart';

class FolderAppBar extends StatelessWidget {
  final String title;
  final bool isRoot;
  final Function()? onBackArrowPressed;

  const FolderAppBar({
    super.key,
    required this.title,
    required this.isRoot,
    this.onBackArrowPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgDarker,
      height: 64,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (!isRoot)
            IconButton(
              onPressed: onBackArrowPressed,
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
          const Spacer(),
          Text(
            title.substring(title.lastIndexOf('/') + 1),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

//////////////////////////////// WIDGETS ////////////////////////////////

//////////////////////////////// LISTENERS ////////////////////////////////

//////////////////////////////// FUNCTIONS ////////////////////////////////
}
