// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';

class Artwork extends StatelessWidget {
  final String artworkPath;

  const Artwork({
    super.key,
    required this.artworkPath,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      // ignore: use_decorated_box
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            width: 2,
            color: Colors.white70,
          ),
        ),
        child: Hero(
          tag: artworkPath,
          child: SizedBox(
            height: MediaQuery.of(context).size.height / 3,
            child: Image.file(File(artworkPath)),
          ),
        ),
      ),
    );
  }

//////////////////////////////// WIDGETS ////////////////////////////////

//////////////////////////////// LISTENERS ////////////////////////////////

//////////////////////////////// FUNCTIONS ////////////////////////////////
}
