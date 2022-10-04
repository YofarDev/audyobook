// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import '../../models/audiobook.dart';
import '../../res/app_colors.dart';
import '../../utils/extensions.dart';
import '../audioplayer/artwork.dart';

class ProgressAudiobook extends StatelessWidget {
  final List<Audiobook> audiobooks;
  final bool minimal;
  final String album;

  const ProgressAudiobook({
    super.key,
    required this.audiobooks,
    this.minimal = false,
    this.album = "",
  });

  @override
  Widget build(BuildContext context) {
    int current = 0;
    int total = 0;
    for (final Audiobook audiobook in audiobooks) {
      current += audiobook.currentPosition.inSeconds;
      total += audiobook.duration.inSeconds;
    }
    if (minimal) {
      return _minimal(current, total);
    } else {
      return _main(current, total);
    }
  }

//////////////////////////////// WIDGETS ////////////////////////////////

  Widget _main(int current, int total) => Column(
        children: <Widget>[
          if (audiobooks.first.artworkPath != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Artwork(artworkPath: audiobooks.first.artworkPath!),
            ),
          Text(
            "${(current / total * 100).toInt()}%",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 4),
            child: LinearProgressIndicator(
              backgroundColor: AppColors.primary,
              color: AppColors.pastille,
              value: current / total,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                current.getFormatedTimer(withHours: true),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              Text(
                total.getFormatedTimer(withHours: true),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      );

  Widget _minimal(
    int current,
    int total,
  ) =>
      Row(
        children: <Widget>[
          Text(
            "$album :",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Montserrat',
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 42, right: 16),
              child: LinearProgressIndicator(
                backgroundColor: AppColors.primary,
                color: AppColors.pastille,
                value: current / total,
              ),
            ),
          ),
          Text(
            "(${(current / total * 100).toInt()}%)",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
            ),
          ),
        ],
      );

//////////////////////////////// LISTENERS ////////////////////////////////

//////////////////////////////// FUNCTIONS ////////////////////////////////
}
