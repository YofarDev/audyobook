// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import '../../res/app_colors.dart';
import '../../utils/app_constants.dart';

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
        children: <Widget>[
          if (!isRoot) const SizedBox(width: 16),
          if (!isRoot)
            IconButton(
              onPressed: onBackArrowPressed,
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
          if (isRoot) const Spacer() else const SizedBox(width: 16),
          Flexible(
            child: Text(
              title.substring(title.lastIndexOf(AppConstants.getSlash()) + 1),
              maxLines: 1,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          if (isRoot) const Spacer(),
        ],
      ),
    );
  }

//////////////////////////////// WIDGETS ////////////////////////////////

//////////////////////////////// LISTENERS ////////////////////////////////

//////////////////////////////// FUNCTIONS ////////////////////////////////
}
