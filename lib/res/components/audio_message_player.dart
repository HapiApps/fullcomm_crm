import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';

const String _audioHost = "anpace.hapirides.in";
const String _audioScript = "/DEV/get_files.php";

String audioFullUrl(String path) {
  final p = path.trim();
  if (p.startsWith("http")) return p;
  return Uri.https(
    _audioHost,
    _audioScript,
    {"path": p.startsWith("/") ? p : "/$p"},
  ).toString();
}

class AudioMessagePlayer extends StatefulWidget {
  final String url;
  const AudioMessagePlayer({super.key, required this.url});

  @override
  State<AudioMessagePlayer> createState() => _AudioMessagePlayerState();
}

class _AudioMessagePlayerState extends State<AudioMessagePlayer> {
  static _AudioMessagePlayerState? _current;

  AudioPlayer? _player;
  final List<StreamSubscription> _subs = [];

  bool _loading = false;
  bool _playing = false;
  bool _error = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  late final List<double> _bars = _buildBars(widget.url);

  static List<double> _buildBars(String seed) {
    final r = Random(seed.hashCode);
    return List.generate(80, (_) => 5 + r.nextDouble() * 17);
  }

  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  Future<void> _initPlayer() async {
    final p = AudioPlayer();
    _player = p;

    _subs.add(p.positionStream.listen((pos) {
      if (mounted) setState(() => _position = pos);
    }));
    _subs.add(p.durationStream.listen((d) {
      if (mounted && d != null) setState(() => _duration = d);
    }));
    _subs.add(p.playerStateStream.listen((s) async {
      if (!mounted) return;
      if (s.processingState == ProcessingState.completed) {
        await p.pause();
        await p.seek(Duration.zero);
      }
      if (mounted) {
        setState(() {
          _playing =
              s.playing && s.processingState != ProcessingState.completed;
        });
      }
    }));

    await p.setUrl(widget.url);
  }

  void _disposePlayer() {
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
    _player?.dispose();
    _player = null;
  }

  Future<void> _toggle() async {
    if (_loading) return;
    try {
      if (_player == null) {
        setState(() {
          _loading = true;
          _error = false;
        });
        await _initPlayer();
        if (mounted) setState(() => _loading = false);
      }

      final p = _player;
      if (p == null || !mounted) return;

      if (p.playing) {
        await p.pause();
        return;
      }

      final other = _current;
      if (other != null && other != this) {
        await other._player?.pause();
      }
      _current = this;

      unawaited(p.play());
    } catch (e) {
      debugPrint("Audio error: $e");
      _disposePlayer();
      if (mounted) {
        setState(() {
          _loading = false;
          _playing = false;
          _error = true;
        });
      }
    }
  }

  @override
  void dispose() {
    if (_current == this) _current = null;
    _disposePlayer();
    super.dispose();
  }

  Widget _waveform() {
    return LayoutBuilder(builder: (context, c) {
      final count = max(8, min(_bars.length, (c.maxWidth / 4).floor()));
      final total = _duration.inMilliseconds;
      final progress = total == 0
          ? 0.0
          : (_position.inMilliseconds / total).clamp(0.0, 1.0);

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (d) async {
          if (_player == null || total == 0) return;
          final ratio = (d.localPosition.dx / c.maxWidth).clamp(0.0, 1.0);
          await _player!
              .seek(Duration(milliseconds: (total * ratio).round()));
        },
        child: SizedBox(
          height: 28,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(count, (i) {
              final active = (i / count) < progress;
              return Container(
                width: 2,
                height: _bars[i],
                margin: const EdgeInsets.only(right: 2),
                decoration: BoxDecoration(
                  color: active ? colorsConst.primary : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final showPos = _playing || _position > Duration.zero;
    final timeText = showPos ? _fmt(_position) : _fmt(_duration);

    return Row(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: _toggle,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: colorsConst.primary,
                shape: BoxShape.circle,
              ),
              child: _loading
                  ? const Padding(
                      padding: EdgeInsets.all(7),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      _playing ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 18,
                    ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(child: _waveform()),
        const SizedBox(width: 6),
        SizedBox(
          width: 34,
          child: _error
              ? const Tooltip(
                  message: "Audio load aagala",
                  child: Icon(Icons.error_outline, color: Colors.red, size: 16),
                )
              : Text(
                  timeText,
                  style: TextStyle(
                    fontSize: 11,
                    color: colorsConst.primary,
                    fontFamily: "Lato",
                  ),
                ),
        ),
      ],
    );
  }
}
