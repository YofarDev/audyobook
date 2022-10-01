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
  final List<String> _children = <String>[];
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
    if (_children.isEmpty) {
      return const Center(child: Text("(vide)"));
    } else {
      return Expanded(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _children.length,
          itemBuilder: (BuildContext context, int index) {
            return _childItem(_children[index]);
          },
        ),
      );
    }
  }

  Widget _childItem(String path) {
    final bool isDirectory = Directory(path).existsSync();
    return InkWell(
      onTap: () => isDirectory ? _onFolderTap(path) : _onAudioFileTap(path),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            leading: isDirectory
                ? const Icon(Icons.folder)
                : const Icon(Icons.play_arrow),
            title: Text(path.substring(path.lastIndexOf('/') + 1)),
          ),
        ),
      ),
    );
  }

//////////////////////////////// LISTENERS ////////////////////////////////

  void _onFolderTap(String path) {
    setState(() {
      _ready = false;
    });
    _currentIndex++;
    _getChildren(path);
  }

  void _onAudioFileTap(String path) {
    final Audiobook audiobook = _audiobooks
        .firstWhere((Audiobook a) => a.id == AppUtils.getIdFromPath(path));
    Navigator.of(context).push(
      MaterialPageRoute<dynamic>(
        builder: (BuildContext context) =>
            AudioplayerPage(audiobook: audiobook),
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

    _children.clear();
    _audiobooks.clear();
    for (final FileSystemEntity item in dir.listSync()) {
      // If not a folder, get infos
      if (!Directory(item.path).existsSync()) {
        _audiobooks.add(await _getAudiobook(item.path));
      }
      _children.add(item.path);
    }
    _children.sort();
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
    final Audiobook audiobook = await AudiobookService.getAudiobook(path);
    log(audiobook.toString());
    return audiobook;
  }
}
