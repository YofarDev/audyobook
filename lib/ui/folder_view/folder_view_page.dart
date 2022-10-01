// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../models/audiobook.dart';
import '../../res/app_colors.dart';
import '../../services/audiobooks_service.dart';
import '../../utils/app_utils.dart';
import '../audioplayer/audioplayer_page.dart';
import '../widgets/folder_app_bar.dart';
import '../widgets/loading_widget.dart';

class FolderViewPage extends StatefulWidget {
  final String folderPath;

  const FolderViewPage({
    super.key,
    required this.folderPath,
  });

  @override
  _FolderViewPageState createState() => _FolderViewPageState();
}

class _FolderViewPageState extends State<FolderViewPage> {
  bool _ready = false;
  final List<String> _folders = <String>[];
  final List<Audiobook> _audiobooks = <Audiobook>[];

  bool isRoot = true;
  final Set<String> _currentNavigation = <String>{};
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _getChildren(widget.folderPath);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        FolderAppBar(
          title: _ready ? _currentNavigation.elementAt(_currentIndex) : "",
          isRoot: isRoot,
          onBackArrowPressed: _onBackArrowPressed,
        ),
        if (_ready) _childrenFolderList() else LoadingWidget(),
      ],
    );
  }

//////////////////////////////// WIDGETS ////////////////////////////////

  Widget _childrenFolderList() {
    if (_folders.isEmpty && _audiobooks.isEmpty) {
      return const Center(child: Text("(vide)"));
    } else {
      return Expanded(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _folders.length + _audiobooks.length,
          itemBuilder: (BuildContext context, int index) {
            if (index < _folders.length && _folders.isNotEmpty) {
              return _folderItem(_folders[index]);
            } else if (_audiobooks.isNotEmpty) {
              final int realIndex = index - _folders.length;
              return _audiobookItem(_audiobooks[realIndex]);
            }
          },
        ),
      );
    }
  }

  Widget _folderItem(String path) {
    return InkWell(
      onTap: () => _onFolderTap(path),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            leading: const Icon(Icons.folder),
            title: Text(path.substring(path.lastIndexOf('/') + 1)),
          ),
        ),
      ),
    );
  }

  Widget _audiobookItem(Audiobook audiobook) {
    return InkWell(
      onTap: () => _onAudioFileTap(audiobook.index),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            leading: const Icon(Icons.play_arrow),
            trailing: audiobook.completed ? _badgeCompleted() : null,
            title: Text(
              audiobook.path.substring(audiobook.path.lastIndexOf('/') + 1),
            ),
          ),
        ),
      ),
    );
  }

  Widget _badgeCompleted() => Container(
        height: 12,
        width: 12,
        decoration: BoxDecoration(
          color: AppColors.pastille,
          borderRadius: BorderRadius.circular(100),
        ),
      );

//////////////////////////////// LISTENERS ////////////////////////////////

  void _onFolderTap(String path) {
    setState(() {
      _ready = false;
    });
    _currentIndex++;
    _getChildren(path);
  }

  void _onAudioFileTap(int index) {
    Navigator.of(context).push(
      MaterialPageRoute<dynamic>(
        builder: (BuildContext context) =>
            AudioplayerPage(audiobooks: _audiobooks, index: index),
      ),
    );
  }

  void _onBackArrowPressed() {
    if (isRoot) return;
    final String last = _currentNavigation.elementAt(_currentIndex - 1);
    _currentNavigation.remove(_currentNavigation.elementAt(_currentIndex));
    _currentIndex--;
    _getChildren(last);
  }

//////////////////////////////// FUNCTIONS ////////////////////////////////

  void _getChildren(String path) async {
    final Directory dir = Directory(path);
    _folders.clear();
    _audiobooks.clear();
    for (final FileSystemEntity item in dir.listSync()) {
      // If not a folder, get audiobook item

      if (!Directory(item.path).existsSync()) {
        final Audiobook audiobook = await _getAudiobook(item.path);

        _audiobooks.add(audiobook);
      } else {
        _folders.add(item.path);
      }
    }
    _sortLists();

    isRoot = path == widget.folderPath;

    if (!isRoot) {
      _currentNavigation.add(path);
    } else {
      _currentNavigation.clear();
      _currentNavigation.add(path);
      _currentIndex = 0;
    }
    setState(() {
      _ready = true;
    });
  }

  Future<Audiobook> _getAudiobook(String path) async {
    final Audiobook audiobook =
        await AudiobookService.getAudiobook(path, forceReload: false);
    log(audiobook.toString());
    return audiobook;
  }

  void _sortLists() {
    _folders.sort();
    _audiobooks.sort(
      (Audiobook a, Audiobook b) => a.name.compareTo(b.name),
    );
    for (int i = 0; i < _audiobooks.length; i++) {
      _audiobooks[i].index = i;
    }
  }
}
