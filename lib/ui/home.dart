import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/app_constants.dart';
import 'folder_view/folder_view_page.dart';
import 'widgets/loading_widget.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? _audiobooksFolderPath;

  @override
  void initState() {
    super.initState();
    _loadAudiobooksFolder();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: GestureDetector(
          onLongPress: (Platform.isAndroid || Platform.isIOS)
              ? _requestPermission
              : null,
          child: Column(
            children: <Widget>[
              if (_audiobooksFolderPath != null)
                Expanded(
                  child: FolderViewPage(
                    folderPath: _audiobooksFolderPath!,
                  ),
                )
              else
                Center(child: LoadingWidget()),
            ],
          ),
        ),
      ),
    );
  }

//////////////////////////////// WIDGETS ////////////////////////////////

//////////////////////////////// LISTENERS ////////////////////////////////

//////////////////////////////// FUNCTIONS ////////////////////////////////

  void _loadAudiobooksFolder() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final List<String> storages =
          await ExternalPath.getExternalStorageDirectories();
      _audiobooksFolderPath = "${storages[1]}/Documents/Audiobooks";
    } else {
      final Directory dir = await getApplicationDocumentsDirectory();
      _audiobooksFolderPath = "${dir.path}${AppConstants.getSlash()}Audiobooks";
    }

    setState(() {});
  }

  Future<void> _requestPermission() async {
    await openAppSettings();
  }
}
