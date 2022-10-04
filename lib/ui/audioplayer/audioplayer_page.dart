// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'dart:ui';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:pausable_timer/pausable_timer.dart';

import '../../models/audiobook.dart';
import '../../res/app_colors.dart';
import '../../services/audiobooks_service.dart';
import '../../services/audioplayer_platform_switch.dart';
import '../../services/shared_preferences_service.dart';
import '../../utils/extensions.dart';
import '../widgets/loading_widget.dart';
import 'artwork.dart';
import 'increment_btn.dart';
import 'toggle_speed_btns.dart';

class AudioplayerPage extends StatefulWidget {
  final List<Audiobook> audiobooks;
  final int index;

  const AudioplayerPage({
    super.key,
    required this.audiobooks,
    required this.index,
  });

  @override
  _AudioplayerPageState createState() => _AudioplayerPageState();
}

class _AudioplayerPageState extends State<AudioplayerPage> {
  // ignore: always_specify_types, prefer_typing_uninitialized_variables
  late var _player;
  late Audiobook _currentAudiobook;
  late int _currentIndex;
  bool _ready = false;

  bool _isPlaying = false;
  late Duration _currentPosition;
  late Duration _duration;
  double _currentSpeed = 1;
  late PausableTimer _timer;
  bool _syncToServer = false;

  @override
  void initState() {
    super.initState();
    AudioplayerPlatformSwitch.init();
    _player = AudioplayerPlatformSwitch.player;
    _currentIndex = widget.index;
    _currentAudiobook = _getCurrentAudiobook();
    _initPlayer();
  }

  @override
  void dispose() {
    _timer.cancel();
    AudioplayerPlatformSwitch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            if (_currentAudiobook.artworkPath != null) _background(),
            if (_ready) _playerWidgets() else LoadingWidget(),
            _topBtns(),
          ],
        ),
      ),
    );
  }

//////////////////////////////// WIDGETS ////////////////////////////////

  Widget _background() => Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fitHeight,
            image: FileImage(
              File(_currentAudiobook.artworkPath!),
            ),
            opacity: 0.4,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            color: AppColors.primary.withOpacity(0.08),
          ),
          // ),
        ),
      );

  Widget _playerWidgets() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: <Widget>[
            const Spacer(),
            if (_currentAudiobook.artworkPath != null) _artwork(),
            const SizedBox(height: 24),
            _nameWidget(),
            const SizedBox(height: 24),
            _playerControls(),
            const SizedBox(height: 24),
            _seekBar(),
            const Spacer(),
            _speedControls(),
            const Spacer(),
          ],
        ),
      );

  Widget _speedControls() => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              (_currentSpeed != 1) ? _getRealDuration() : " ",
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          ToggleSpeedBtns(
            currentSpeed: _currentSpeed,
            onChanged: _onSpeedChanged,
          ),
        ],
      );

  Widget _playerControls() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IncrementBtn(
            value: -30,
            onPressed: _onIncrementBtnPressed,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _playPauseBtn(),
          ),
          IncrementBtn(
            value: 30,
            onPressed: _onIncrementBtnPressed,
          ),
        ],
      );

  Widget _topBtns() => Positioned(
        left: 16,
        top: 0,
        right: 16,
        child: Row(
          children: <Widget>[
            IconButton(
              onPressed: _onBackArrowPressed,
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            Column(
              children: <Widget>[
                IconButton(
                  onPressed: _onCloudUploadPressed,
                  icon: Icon(
                    Icons.cloud_upload,
                    color: _syncToServer ? AppColors.primary : Colors.white,
                  ),
                ),
                const Text(
                  "Sauvegarder",
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Column(
              children: <Widget>[
                IconButton(
                  onPressed: _onCloudDownloadPressed,
                  icon: const Icon(
                    Icons.cloud_download,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  "Charger",
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _playPauseBtn() => FloatingActionButton(
        onPressed: _onPlayPauseBtnPressed,
        child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
      );

  Widget _seekBar() => StreamBuilder<Duration>(
        stream: AudioplayerPlatformSwitch.getPositionStream(),
        builder: (BuildContext context, AsyncSnapshot<Duration> snapshot) {
          _currentPosition = snapshot.data ?? Duration.zero;

          return ProgressBar(
            progressBarColor: AppColors.primary,
            thumbColor: AppColors.primary,
            baseBarColor: Colors.white.withOpacity(0.24),
            progress: _currentPosition,
            timeLabelTextStyle: const TextStyle(color: Colors.white),
            total: _duration,
            onSeek: (Duration duration) {
              _player.seek(duration);
            },
          );
        },
      );
  Widget _artwork() => Artwork(
        artworkPath: _currentAudiobook.artworkPath!,
      );

  Widget _nameWidget() => Text(
        _currentAudiobook.name,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );

//////////////////////////////// LISTENERS ////////////////////////////////

  void _onBackArrowPressed() {
    AudioplayerPlatformSwitch.dispose();
    Navigator.of(context).pop();
  }

  void _onPlayPauseBtnPressed() {
    if (_isPlaying) {
      _player.pause();
      _timer.pause();
    } else {
      AudioplayerPlatformSwitch.play();
      _timer.start();
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _onIncrementBtnPressed(int value) async {
    final Duration pos = Duration(
      seconds: (await AudioplayerPlatformSwitch.getCurrentPosition() ??
                  Duration.zero)
              .inSeconds +
          value,
    );
    _player.seek(pos);
  }

  void _onSpeedChanged(double value) {
    AudioplayerPlatformSwitch.setSpeed(value);

    setState(() {
      _currentSpeed = value;
    });
  }

  void _onCloudDownloadPressed() async {
    _currentPosition =
        await AudiobookService.getPositionFromServer(_currentAudiobook);
    _player.seek(_currentPosition);
  }

  void _onCloudUploadPressed() async {
    setState(() {
      _syncToServer = !_syncToServer;
    });
    await _savePositionOnServer();
  }

  void _onCompleted() async {
    _timer.cancel();
    setState(() {
      _ready = false;
    });

    await SharedPreferencesService.saveAudiobookInCache(
      _currentAudiobook,
    );
    await AudiobookService.savePositionToServer(
      widget.audiobooks[_currentIndex],
      widget.audiobooks[_currentIndex].duration,
    );
    if (_currentIndex + 1 <= widget.audiobooks.length) {
      _currentIndex++;
    } else {
      _currentIndex = 0;
    }
    _currentAudiobook = _getCurrentAudiobook();

    _initPlayer();
  }

//////////////////////////////// FUNCTIONS ////////////////////////////////

  Future<void> _initPlayer() async {
    //  await _player.setAudioSource(_currentAudiobook.toAudioSource());
    await AudioplayerPlatformSwitch.setAudioSource(_currentAudiobook);
    _duration = _currentAudiobook.duration;

    _currentPosition = _currentAudiobook.isCompleted()
        ? Duration.zero
        : _currentAudiobook.currentPosition;

    await _player.seek(_currentPosition);
    await AudioplayerPlatformSwitch.setSpeed(_currentSpeed);
    _initListeners();
    AudioplayerPlatformSwitch.play();
    _isPlaying = true;
    _startTimer();
    setState(() {
      _ready = true;
    });
    _updateLastPlayed();
  }

  void _initListeners() {
    if (Platform.isAndroid || Platform.isIOS) {
      _player.playerStateStream.listen((PlayerState playerState) async {
        if (playerState.processingState == ProcessingState.completed) {
          if (!_ready) {
            _initPlayer();
          } else {
            _onCompleted();
          }
        }
        setState(() {
          _isPlaying = playerState.playing;
        });
      });
    } else {
      _player.onPlayerComplete.listen((void event) async {
        if (!_ready) {
          _initPlayer();
        } else {
          _onCompleted();
        }
      });
    }
  }

  void _startTimer() {
    _timer = PausableTimer(const Duration(seconds: 1), () {
      setState(() {});
      if (!mounted) return;

      // Save locally every 5s
      if (_timer.tick % 5 == 0) {
        _savePositionLocally();
      }
      // Save on server every 30s
      if (_timer.tick % 30 == 0 && _syncToServer) {
        _savePositionOnServer();
      }
      _timer
        ..reset()
        ..start();
    });
    _timer.start();
  }

  Future<void> _savePositionOnServer() async {
    await AudiobookService.savePositionToServer(
      _currentAudiobook,
      _currentPosition,
    );
  }

  void _savePositionLocally() async {
    _currentAudiobook.currentPosition = _currentPosition;
    await SharedPreferencesService.saveAudiobookInCache(_currentAudiobook);
  }

  String _getRealDuration() {
    final String left =
        ((_currentAudiobook.duration.inSeconds - _currentPosition.inSeconds) *
                (1 / _currentSpeed))
            .toInt()
            .getFormatedTimer();
    final String length =
        (_currentAudiobook.duration.inSeconds * (1 / _currentSpeed))
            .toInt()
            .getFormatedTimer();
    return "Temps restant réel :   -$left / $length";
  }

  Audiobook _getCurrentAudiobook() => widget.audiobooks.firstWhere(
        (Audiobook a) => a.index == _currentIndex,
      );

  void _updateLastPlayed() async {
    await AudiobookService.saveLastPlayed(_currentAudiobook);
  }
}
