// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';
import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../models/audiobook.dart';
import '../../models/last_played.dart';
import '../../res/app_colors.dart';
import '../../services/audiobooks_service.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_utils.dart';
import '../audioplayer/audioplayer_page.dart';
import '../widgets/folder_app_bar.dart';
import '../widgets/loading_widget.dart';
import 'progress_audiobook.dart';

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

  bool _isRoot = true;
  final Set<String> _currentNavigation = <String>{};
  int _currentIndex = 0;
  LastPlayed? _lastPlayed;

  @override
  void initState() {
    super.initState();
    _getChildren(widget.folderPath);
    _getLastPlayed();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        FolderAppBar(
          title: _ready ? _currentNavigation.elementAt(_currentIndex) : "",
          isRoot: _isRoot,
          onBackArrowPressed: _onBackArrowPressed,
        ),
        if (_lastPlayed != null) _lastPlayedWidget(),
        if (_ready)
          _childrenFolderList()
        else
          Column(
            children: <Widget>[
              const SizedBox(height: 32),
              LoadingWidget(),
            ],
          ),
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
              return Column(
                children: <Widget>[
                  if (realIndex == 0 && _audiobooks.isNotEmpty && _ready)
                    _infosBook(),
                  _audiobookItem(_audiobooks[realIndex]),
                ],
              );
            } else {
              return null;
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
            title: Text(
              path.substring(path.lastIndexOf(AppConstants.getSlash()) + 1),
              style: const TextStyle(fontFamily: "Montserrat"),
            ),
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
            trailing: _getPastille(audiobook),
            title: Text(
              audiobook.path.substring(
                audiobook.path.lastIndexOf(AppConstants.getSlash()) + 1,
              ),
              style: const TextStyle(fontFamily: "Montserrat"),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getPastille(Audiobook audiobook) {
    Color? color;
    if (audiobook.isCompleted()) {
      color = AppColors.pastille;
    } else if (audiobook.currentPosition.inSeconds > 0) {
      color = Colors.green;
    }
    return Container(
      height: 12,
      width: 12,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }

  Widget _infosBook() => Padding(
    padding: const EdgeInsets.all(16),
    child: ProgressAudiobook(
          audiobooks: _audiobooks,
        ),
  );

  Widget _lastPlayedWidget() => Padding(
        padding: const EdgeInsets.all(16),
        child: InkWell(
          onTap: _openLastPlayed,
          child: ListTile(
            leading: const Icon(Icons.play_arrow, color: Colors.white),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  "Dernier joué :",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_lastPlayed!.album} (${_lastPlayed!.title})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ),
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
    Navigator.of(context)
        .push(
          MaterialPageRoute<dynamic>(
            builder: (BuildContext context) =>
                AudioplayerPage(audiobooks: _audiobooks, index: index),
          ),
        )
        .then(
          (_) => setState(() {
            _getChildren(_currentNavigation.elementAt(_currentIndex));
          }),
        );
  }

  void _onBackArrowPressed() {
    if (_isRoot) return;
    final String last = _currentNavigation.elementAt(_currentIndex - 1);
    _currentNavigation.remove(_currentNavigation.elementAt(_currentIndex));
    _currentIndex--;
    _getChildren(last);
  }

  void _openLastPlayed() async {
    final String path = AppUtils.getPathFromId(_lastPlayed!.id);
    final List<String> folders = path.split(AppConstants.getSlash());
    String pathTo = widget.folderPath;
    _currentNavigation.clear();
    _currentNavigation.add(widget.folderPath);
    _currentIndex = 0;
    for (final String f in folders) {
      if (f != folders.last) {
        pathTo = "$pathTo${AppConstants.getSlash()}$f";
        _currentNavigation.add(pathTo);
      }
    }
    _currentIndex = _currentNavigation.length - 1;
    _isRoot = false;
    final Directory dir = Directory(pathTo);
    final List<FileSystemEntity> filesList = dir.listSync();
    _audiobooks.clear();
    _folders.clear();
    for (final FileSystemEntity item in filesList) {
      // If not a folder, get audiobook item
      if (!Directory(item.path).existsSync()) {
        if (!item.path.endsWith('.mp3')) continue;
        final Audiobook audiobook = await _getAudiobook(item.path);
        _audiobooks.add(audiobook);
      } else {
        _folders.add(item.path);
      }
    }
    _sortLists();
    final int index =
        _audiobooks.indexWhere((Audiobook a) => a.id == _lastPlayed!.id);
    _audiobooks[index].currentPosition =
        await AudiobookService.getPositionFromServer(_audiobooks[index]);
    _onAudioFileTap(index);
  }

//////////////////////////////// FUNCTIONS ////////////////////////////////

  void _getChildren(String path) async {
    final Directory dir = Directory(path);
    _folders.clear();
    _audiobooks.clear();
    final List<FileSystemEntity> filesList = dir.listSync();
    for (final FileSystemEntity item in filesList) {
      // If not a folder, get audiobook item
      if (!Directory(item.path).existsSync()) {
        if (!item.path.endsWith('.mp3')) continue;
        final Audiobook audiobook = await _getAudiobook(item.path);
        _audiobooks.add(audiobook);
      } else {
        _folders.add(item.path);
      }
    }
    await _getSavedPositions();
    _sortLists();

    _isRoot = path == widget.folderPath;

    if (!_isRoot) {
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
    final Audiobook audiobook = await AudiobookService.getAudiobook(
      path,
      //  forceReload: false,
    );
    log(audiobook.toString());
    return audiobook;
  }

  void _sortLists() {
    _folders.sort(compareNatural);
    _audiobooks.sort(
      (Audiobook a, Audiobook b) => a.name.compareTo(b.name),
    );
    for (int i = 0; i < _audiobooks.length; i++) {
      _audiobooks[i].index = i;
    }
  }

  Future<void> _getSavedPositions() async {
    if (_audiobooks.isEmpty) {
      return;
    }
    final Map<String, Duration> map =
        await AudiobookService.getAllPostionsForAlbum(_audiobooks.first.album);
    for (final Audiobook audiobook in _audiobooks) {
      if (map[audiobook.id] != null) {
        audiobook.currentPosition = map[audiobook.id]!;
      }
    }
  }

  Future<void> _getLastPlayed() async {
    _lastPlayed = await AudiobookService.getLastPlayed();
    if (_lastPlayed != null) setState(() {});
  }
}
