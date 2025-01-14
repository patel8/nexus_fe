import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;

  const AudioPlayerWidget({super.key, required this.audioUrl});

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _totalDuration = Duration.zero;
  Duration _currentPosition = Duration.zero;

  Timer? _sliderUpdateTimer; // To throttle position updates

  @override
  void initState() {
    super.initState();

    // Listen for total duration once
    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _totalDuration = duration;
        });
      }
    });

    // Throttle position updates
    _audioPlayer.onPositionChanged.listen((position) {
      if (_sliderUpdateTimer?.isActive ?? false) return;

      _sliderUpdateTimer = Timer(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            _currentPosition = position;
          });
        }
      });
    });

    // Handle audio completion
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _currentPosition = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _sliderUpdateTimer?.cancel();
    super.dispose();
  }

  Future<void> _playAudio() async {
    setState(() => _isLoading = true);
    try {
      await _audioPlayer.play(UrlSource(widget.audioUrl));
      if (mounted) {
        setState(() {
          _isPlaying = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to play audio: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isLoading)
            const CircularProgressIndicator()
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 32,
                  ),
                  onPressed: _isPlaying
                      ? () async {
                          await _audioPlayer.pause();
                          if (mounted) {
                            setState(() => _isPlaying = false);
                          }
                        }
                      : _playAudio,
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: _currentPosition.inSeconds.toDouble(),
                      min: 0,
                      max: _totalDuration.inSeconds.toDouble(),
                      onChanged: (value) async {
                        final newPosition = Duration(seconds: value.toInt());
                        await _audioPlayer.seek(newPosition);
                        if (mounted) {
                          setState(() => _currentPosition = newPosition);
                        }
                      },
                      activeColor: Colors.blue,
                      inactiveColor: Colors.grey.shade300,
                    ),
                  ),
                ),
                _buildTimeDisplay(_currentPosition),
                _buildTimeDisplay(_totalDuration),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTimeDisplay(Duration duration) {
    return SizedBox(
      width: 40,
      child: Text(
        _formatDuration(duration),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        textAlign: TextAlign.center,
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
