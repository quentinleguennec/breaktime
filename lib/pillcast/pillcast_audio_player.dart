import 'dart:async';

import 'package:aebeze/services/injector.dart';
import 'package:aebeze/services/memory_cache.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/services/user_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

enum PlayerState { STOPPED, PLAYING, PAUSED }

class PillcastAudioPlayer {
  final StreamController<PillcastAudioPlayerState> _streamController =
      StreamController<PillcastAudioPlayerState>.broadcast();
  final AudioPlayer _audioPlayer = new AudioPlayer();

  StreamSubscription _onAudioPlayerCompletionSubscription;
  PillcastAudioPlayerState _state;
  List<PillcastAudioTrack> _playList;
  int _currentTrackIndexInPlayList = 0;
  UserService _userService;
  MemoryCache _cache;

  /// Those bool are to avoid calling the plugin functions too fast if the users mash the back or next buttons
  /// (the plugin doesn't like it).
  /// It also synchronize the async calls and avoid ending-up in a wrong state like having 2 calls to the same
  /// function changing the same value between 2 await (concurrent access).
  bool _isChangingTrack = false;
  bool _isStartingPlaying = false;
  bool _isStartingPlayingPrevious = false;
  bool _isStartingPlayingNext = false;
  bool _isStartingPlayingCurrent = false;
  bool _isStartingPlayingPlayList = false;
  bool _isStartingPausing = false;
  bool _isStartingStopping = false;
  bool _isStartingResuming = false;

  Stream<PillcastAudioPlayerState> get stream => _streamController.stream;

  PillcastAudioPlayerState get state => _state;

  PillcastAudioTrack get currentTrack => _playList[_currentTrackIndexInPlayList];

  PillcastAudioPlayer() {
    /// For Android, else trying to load the same track very fast (mashing the back button on the first track) causes a crash in the plugin.
    _audioPlayer.setReleaseMode(ReleaseMode.STOP);
    _userService = Injector().userService;
    _cache = Injector().cache;
    _state = PillcastAudioPlayerState();
    _streamController.sink.add(state);
    _loadUserData();
    _onAudioPlayerCompletionSubscription = _audioPlayer.onPlayerCompletion.listen((_) => _onTrackCompleted());
  }

  void dispose() {
    if (!state.isStopped) {
      _updateUserData();
    }
    _onAudioPlayerCompletionSubscription?.cancel();
    _audioPlayer.stop().then((_) => _audioPlayer.release().then((_) => _audioPlayer.dispose()));
    _streamController.close();
  }

  void _loadUserData() async {
    List<String> uids = await _userService.loadPillcastCompletedTrackUids();
    _cache.userPillcastCompletedTracksUids = Set.of(uids);
  }

  void _updateState(PillcastAudioPlayerState newState) {
    _state = newState;
    _streamController.sink.add(_state);
  }

  Future<void> _updateUserData() async {
    int position = await _audioPlayer?.getCurrentPosition();
    int duration = await _audioPlayer?.getDuration();
    if (position == null || duration == null || duration == 0) {
      return;
    }
    double playedRatio = (position / duration).clamp(0.0, 1.0);

    _cache.addUserPillcastTrackCompletedUid(currentTrack.uid);
    _userService.savePillcastCompletedTrack(currentTrack.uid, playedRatio);
  }

  Future _onTrackCompleted() async {
    if (_isChangingTrack) return;
    _isChangingTrack = true;

    await playNext();

    _isChangingTrack = false;
  }

  Future playPlayList(List<PillcastAudioTrack> playList, {startingTrackIndex = 0}) async {
    if (_isStartingPlayingPlayList) return;
    _isStartingPlayingPlayList = true;

    if (playList == _playList && startingTrackIndex == _currentTrackIndexInPlayList) {
      _isStartingPlayingPlayList = false;
      return;
    }
    await stop();
    _playList = playList;
    _currentTrackIndexInPlayList = startingTrackIndex;
    await playCurrent();

    _isStartingPlayingPlayList = false;
  }

  Future playCurrent() async {
    if (_isStartingPlayingCurrent) return;
    _isStartingPlayingCurrent = true;

    if (_playList == null || _playList.isEmpty) return;
    if (state.isPaused) {
      await resume();
    } else {
      await stop();
      await play(currentTrack);
    }
    _isStartingPlayingCurrent = false;
  }

  Future play(PillcastAudioTrack track) async {
    if (_isStartingPlaying) return;
    _isStartingPlaying = true;

    await stop();
    int trackIndexInPlayList = _playList?.indexOf(track);
    if (trackIndexInPlayList == null || trackIndexInPlayList == -1) {
      print("Error: track not in current playlist!");
      _isStartingPlaying = false;
      return;
    }
    _currentTrackIndexInPlayList = trackIndexInPlayList;
    await _audioPlayer.play(track.url);
    _updateState(_state.copyWith(playerState: PlayerState.PLAYING, trackPlaying: track));

    _isStartingPlaying = false;
  }

  Future pause() async {
    if (_isStartingPausing) return;
    _isStartingPausing = true;

    await _audioPlayer.pause();
    _updateState(_state.copyWith(playerState: PlayerState.PAUSED));

    _isStartingPausing = false;
  }

  Future stop() async {
    if (_isStartingStopping) return;
    _isStartingStopping = true;

    if (state.isStopped) {
      _isStartingStopping = false;
      return;
    }
    await _updateUserData();
    await _audioPlayer.stop();
    _updateState(_state.copyWith(playerState: PlayerState.STOPPED));

    _isStartingStopping = false;
  }

  Future resume() async {
    if (_isStartingResuming) return;
    _isStartingResuming = true;

    await _audioPlayer.resume();
    _updateState(_state.copyWith(playerState: PlayerState.PLAYING));

    _isStartingResuming = false;
  }

  Future playNext() async {
    if (_isStartingPlayingNext) return;
    _isStartingPlayingNext = true;

    await stop();
    if (_currentTrackIndexInPlayList + 1 < _playList.length) {
      _currentTrackIndexInPlayList += 1;
    } else {
      _currentTrackIndexInPlayList = 0;
    }
    await play(currentTrack);

    _isStartingPlayingNext = false;
  }

  Future playPrevious() async {
    if (_isStartingPlayingPrevious) return;
    _isStartingPlayingPrevious = true;

    await stop();
    if (_currentTrackIndexInPlayList > 0) {
      _currentTrackIndexInPlayList -= 1;
    } else {
      _currentTrackIndexInPlayList = _playList.length - 1;
    }
    await play(currentTrack);

    _isStartingPlayingPrevious = false;
  }
}

@immutable
class PillcastAudioPlayerState {
  final PlayerState _playerState;
  final PillcastAudioTrack trackPlaying;

  bool get isPlaying => isInitialized && _playerState == PlayerState.PLAYING;

  bool get isPaused => isInitialized && _playerState == PlayerState.PAUSED;

  bool get isStopped => !isInitialized || _playerState == PlayerState.STOPPED;

  bool get isInitialized => trackPlaying != null;

  PillcastAudioPlayerState({
    PlayerState playerState = PlayerState.STOPPED,
    this.trackPlaying,
  }) : _playerState = playerState;

  PillcastAudioPlayerState copyWith({
    PlayerState playerState,
    PillcastAudioTrack trackPlaying,
  }) =>
      PillcastAudioPlayerState(
        playerState: playerState ?? this._playerState,
        trackPlaying: trackPlaying ?? this.trackPlaying,
      );
}
