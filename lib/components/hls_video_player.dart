import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:tvplus/player_status.dart';
import 'dart:async';
import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:tvplus/components/web_video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

@NowaGenerated()
class HlsVideoPlayer extends StatefulWidget {
  @NowaGenerated({'loader': 'auto-constructor'})
  const HlsVideoPlayer({
    required this.url,
    this.userAgent,
    this.referer,
    this.onStatusChanged,
    this.logoUrl,
    super.key,
  });

  final String url;

  final String? userAgent;

  final String? referer;

  final void Function(PlayerStatus status, String message)? onStatusChanged;

  final String? logoUrl;

  @override
  State<HlsVideoPlayer> createState() {
    return _HlsVideoPlayerState();
  }
}

@NowaGenerated()
class _HlsVideoPlayerState extends State<HlsVideoPlayer> {
  VideoPlayerController? _videoPlayerController;

  ChewieController? _chewieController;

  bool _isInitialized = false;

  String? _errorMessage;

  int _retryCount = 0;

  PlayerStatus _currentStatus = PlayerStatus.connecting;

  Timer? _retryTimer;

  bool _showControls = true;

  Timer? _controlsTimer;

  bool _showSkipForward = false;

  bool _showSkipBackward = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void didUpdateWidget(HlsVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _retryCount = 0;
      _currentStatus = PlayerStatus.connecting;
      _initializePlayer();
    }
  }

  void _updateStatus(PlayerStatus status, String message) {
    if (!mounted) {
      return;
    }
    setState(() {
      _currentStatus = status;
    });
    widget.onStatusChanged?.call(status, message);
  }

  void _skip(int seconds) {
    if (_videoPlayerController == null ||
        !_videoPlayerController!.value.isInitialized) {
      return;
    }
    final newPosition =
        _videoPlayerController!.value.position + Duration(seconds: seconds);
    _videoPlayerController?.seekTo(newPosition);
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startControlsTimer();
    }
  }

  void _startControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _handleDoubleTap(Offset position) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (position.dx < screenWidth / 2) {
      _skip(-10);
      setState(() => _showSkipBackward = true);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() => _showSkipBackward = false);
        }
      });
    } else {
      _skip(10);
      setState(() => _showSkipForward = true);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() => _showSkipForward = false);
        }
      });
    }
  }

  Widget _skipIndicator(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.black45,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 40),
    );
  }

  Widget _buildCustomControls() {
    return Positioned.fill(
      child: AnimatedOpacity(
        opacity: _showControls ? 1 : 0,
        duration: const Duration(milliseconds: 300),
        child: IgnorePointer(
          ignoring: !_showControls,
          child: Container(
            color: Colors.black26,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _controlButton(
                      icon: Icons.replay_10,
                      onPressed: () => _skip(-10),
                    ),
                    const SizedBox(width: 32),
                    _controlButton(
                      icon: _videoPlayerController!.value.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 64,
                      onPressed: () {
                        setState(() {
                          _videoPlayerController!.value.isPlaying
                              ? _videoPlayerController?.pause()
                              : _videoPlayerController?.play();
                        });
                        _startControlsTimer();
                      },
                    ),
                    const SizedBox(width: 32),
                    _controlButton(
                      icon: Icons.forward_10,
                      onPressed: () => _skip(10),
                    ),
                  ],
                ),
                const Spacer(),
                _buildSeekBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required void Function() onPressed,
    double size = 32,
  }) {
    return IconButton(
      icon: Icon(icon, color: Colors.white, size: size),
      onPressed: onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: IndexedStack(
        index: _currentStatus == PlayerStatus.webFallback ? 1 : 0,
        children: [
          _buildNativePlayer(),
          WebVideoPlayer(
            url: widget.url,
            userAgent: widget.userAgent,
            referer: widget.referer,
          ),
        ],
      ),
    );
  }

  void _listener() {
    if (!mounted || _videoPlayerController == null) {
      return;
    }
    final value = _videoPlayerController?.value;
    if (value!.hasError) {
      _handleError(value?.errorDescription ?? 'Error desconocido');
    } else if (value!.isBuffering) {
    } else if (value!.isPlaying) {
      if (_currentStatus != PlayerStatus.playing) {
        _updateStatus(PlayerStatus.playing, 'En vivo');
        _retryCount = 0;
      }
    } else if (_isInitialized &&
        !value!.isPlaying &&
        !value!.isBuffering &&
        _currentStatus == PlayerStatus.playing) {
      _handleError('Playback stalled');
    }
  }

  void _handleError(String error) {
    if (_currentStatus == PlayerStatus.webFallback) {
      return;
    }
    if (_retryCount < 2) {
      _retryCount++;
      _updateStatus(PlayerStatus.retrying, 'Reconectando...');
      _retryTimer?.cancel();
      _retryTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          _initializePlayer();
        }
      });
    } else {
      _updateStatus(PlayerStatus.webFallback, 'Modo Alternativo');
    }
  }

  Widget _buildSeekBar() {
    final duration = _videoPlayerController!.value.duration;
    final position = _videoPlayerController!.value.position;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                activeTrackColor: Colors.red,
                inactiveTrackColor: Colors.white24,
                thumbColor: Colors.red,
              ),
              child: Slider(
                value: position.inSeconds.toDouble().clamp(
                  0,
                  duration.inSeconds.toDouble(),
                ),
                max: duration.inSeconds.toDouble() > 0
                    ? duration.inSeconds.toDouble()
                    : 1,
                onChanged: (value) {
                  _videoPlayerController?.seekTo(
                    Duration(seconds: value.toInt()),
                  );
                  _startControlsTimer();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNativePlayer() {
    final bool hasError =
        _errorMessage != null ||
        (_videoPlayerController?.value.hasError ?? false);
    final String? logoUrl = widget.logoUrl;
    return Stack(
      alignment: Alignment.center,
      children: [
        if (logoUrl != null && (!_isInitialized || hasError))
          Positioned.fill(
            child: Image.network(
              logoUrl,
              fit: BoxFit.cover,
              color: Colors.black.withValues(alpha: 0.5),
              colorBlendMode: BlendMode.darken,
            ),
          ),
        if (_videoPlayerController != null && _isInitialized && !hasError)
          GestureDetector(
            onTap: _toggleControls,
            onDoubleTapDown: (details) =>
                _handleDoubleTap(details.localPosition),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: VideoPlayer(_videoPlayerController!),
            ),
          )
        else if (!hasError)
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Cargando...',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        if (_showSkipBackward)
          Positioned(left: 40, child: _skipIndicator(Icons.replay_10)),
        if (_showSkipForward)
          Positioned(right: 40, child: _skipIndicator(Icons.forward_10)),
        if (_isInitialized && !hasError) _buildCustomControls(),
        if (_currentStatus == PlayerStatus.retrying ||
            _currentStatus == PlayerStatus.connecting)
          Positioned(
            bottom: 80,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _currentStatus == PlayerStatus.retrying
                    ? 'Reconectando...'
                    : 'Conectando...',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _initializePlayer() async {
    if (_currentStatus == PlayerStatus.webFallback) {
      return;
    }
    setState(() {
      _isInitialized = false;
      _errorMessage = null;
    });
    try {
      _chewieController?.dispose();
      _videoPlayerController?.dispose();
      _chewieController = null;
      _videoPlayerController = null;
      await WakelockPlus.enable();
      final Map<String, String> headers = {
        'User-Agent':
            widget.userAgent ??
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Accept': '*/*',
        'Connection': 'keep-alive',
      };
      final Uri uri = Uri.parse(widget.url);
      final String? currentReferer = widget.referer;
      if (currentReferer != null && currentReferer!.isNotEmpty) {
        headers['Referer'] = currentReferer;
      }
      _videoPlayerController = VideoPlayerController.networkUrl(
        uri,
        httpHeaders: headers,
        videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true),
      );
      await _videoPlayerController?.initialize();
      if (_videoPlayerController != null) {
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController!,
          aspectRatio: 16 / 9,
          autoPlay: true,
          isLive: true,
          showControls: false,
        );
        _videoPlayerController?.play();
      }
      _videoPlayerController?.addListener(_listener);
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _showControls = true;
        });
        _startControlsTimer();
      }
    } catch (e) {
      _handleError(e.toString());
    }
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _controlsTimer?.cancel();
    _videoPlayerController?.removeListener(_listener);
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    WakelockPlus.disable();
    super.dispose();
  }
}
