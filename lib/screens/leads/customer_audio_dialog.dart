import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:record/record.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:fullcomm_crm/services/api_services.dart';

import '../../services/api/audio_api.dart';

void showCustomerAudioDialog(BuildContext context,
    {required String customerId, required String customerName}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) =>
        CustomerAudioDialog(customerId: customerId, customerName: customerName),
  );
}

enum _Mode { list, recording, recorded }

class CustomerAudioDialog extends StatefulWidget {
  final String customerId;
  final String customerName;
  const CustomerAudioDialog(
      {super.key, required this.customerId, required this.customerName});

  @override
  State<CustomerAudioDialog> createState() => _CustomerAudioDialogState();
}

class _CustomerAudioDialogState extends State<CustomerAudioDialog> {
  static const int _maxSeconds = 300;
  static const int _maxBytes = 20 * 1024 * 1024;

  late Future<List<CustomerAudio>> _future;
  final AudioPlayer _player = AudioPlayer();
  final AudioRecorder _recorder = AudioRecorder();
  final TextEditingController _titleCtr = TextEditingController();


  _Mode _mode = _Mode.list;
  String? _playingUrl;
  bool _saving = false;
  Timer? _timer;
  int _seconds = 0;
  String? _recordedPath;
  String _ext = 'webm';
  DateTime? _endedAt;
  int _durationSec = 0;

  @override
  void initState() {
    super.initState();
    _future = apiService.getCustomerAudios(widget.customerId);
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playingUrl = null);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _player.dispose();
    _recorder.dispose();
    _titleCtr.dispose();
    _endedAt = null;
    _durationSec = 0;
    super.dispose();
  }
  String _fmtDur(int s) {
    final m = s ~/ 60;
    final r = s % 60;
    if (m == 0) return '$r secs';
    if (r == 0) return '$m ${m == 1 ? 'min' : 'mins'}';
    return '$m ${m == 1 ? 'min' : 'mins'} $r secs';
  }

  String _fmtTs(String raw) {
    if (raw.isEmpty) return '';
    final d = DateTime.tryParse(raw);
    if (d == null) return raw;
    return DateFormat('dd MMM yyyy hh:mm a').format(d);
  }

  String _fmt(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  void _reload() {
    setState(() {
      _future = apiService.getCustomerAudios(widget.customerId);
    });
  }


  Future<void> _startRecording() async {
    try {
      if (!await _recorder.hasPermission()) {
        if (mounted) {
          utils.snackBar(
              context: context,
              msg: "Microphone permission is blocked. Click the lock icon in the address bar and allow Microphone.",
              color: Colors.red);
        }
        return;
      }
      await _player.stop();
      _playingUrl = null;

      final opusOk = await _recorder.isEncoderSupported(AudioEncoder.opus);
      _ext = opusOk ? 'webm' : 'wav';
      await _recorder.start(
        RecordConfig(encoder: opusOk ? AudioEncoder.opus : AudioEncoder.wav),
        path: '',
      );

      _seconds = 0;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _seconds++);
        if (_seconds >= _maxSeconds) _stopRecording();
      });
      setState(() => _mode = _Mode.recording);
    } catch (e) {
      if (mounted) {
        utils.snackBar(
            context: context, msg: "Could not start recording: $e", color: Colors.red);
      }
    }
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    final path = await _recorder.stop();
    if (!mounted) return;
    _recordedPath = path;
    _endedAt = DateTime.now();
    _durationSec = _seconds;
    if (path == null) {
      setState(() => _mode = _Mode.list);
      return;
    }
    _recordedPath = path;
    _titleCtr.text = 'Voice note ${DateFormat('dd-MM HH:mm').format(DateTime.now())}';
    setState(() => _mode = _Mode.recorded);
  }

  Future<void> _discard() async {
    await _player.stop();
    setState(() {
      _recordedPath = null;
      _playingUrl = null;
      _mode = _Mode.list;
    });
  }

  Future<void> _save() async {
    if (_recordedPath == null) return;
    setState(() => _saving = true);
    try {
      await _player.stop();
      final res = await http.get(Uri.parse(_recordedPath!)); // blob -> bytes
      final bytes = res.bodyBytes;

      if (bytes.length > _maxBytes) {
        if (mounted) {
          utils.snackBar(
              context: context, msg: "Recording too long (max 20 MB)", color: Colors.red);
        }
        return;
      }

      final ok = await apiService.insertCustomerAudio(
        customerId: widget.customerId,
        title: 'Voice Note',
        bytes: bytes,
        fileName: 'voice_${DateTime.now().millisecondsSinceEpoch}.$_ext',
        endTs: DateFormat('yyyy-MM-dd HH:mm:ss').format(_endedAt!),
        durationSec: _durationSec,
      );

      if (ok && mounted) {
        utils.snackBar(context: context, msg: "Audio saved", color: Colors.green);
        setState(() {
          _recordedPath = null;
          _playingUrl = null;
          _mode = _Mode.list;
          _endedAt = null;
          _durationSec = 0;
        });
        _reload();
      }
    } catch (e) {
      debugPrint("Save failed: $e");
      if (mounted) {
        utils.snackBar(context: context, msg: "Save failed: $e", color: Colors.red);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ───────────── PLAY ─────────────

  Future<void> _toggle(String url) async {
    if (_playingUrl == url) {
      await _player.stop();
      setState(() => _playingUrl = null);
    } else {
      await _player.stop();
      await _player.play(UrlSource(url));
      setState(() => _playingUrl = url);
    }
  }

  Future<void> _close() async {
    if (_mode == _Mode.recording) {
      _timer?.cancel();
      await _recorder.stop();
    }
    await _player.stop();
    if (mounted) Navigator.pop(context);
  }

  // ───────────── UI ─────────────

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Expanded(
            child: Text("Customer Audio - ${widget.customerName}",
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          if (_mode == _Mode.list)
            Tooltip(
              message: "Record voice",
              child: IconButton(
                icon: Icon(Icons.mic, color: colorsConst.primary, size: 28),
                onPressed: _startRecording,
              ),
            ),
          IconButton(icon: const Icon(Icons.close), onPressed: _close),
        ],
      ),
      content: SizedBox(
        width: 450,
        height: 320,
        child: switch (_mode) {
          _Mode.recording => _recordingPanel(),
          _Mode.recorded => _recordedPanel(),
          _Mode.list => _listPanel(),
        },
      ),
    );
  }

  Widget _recordingPanel() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.mic, color: Colors.red, size: 64),
        const SizedBox(height: 12),
        Text(_fmt(_seconds),
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text("Recording... speak now (max ${_fmt(_maxSeconds)})",
            style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, foregroundColor: Colors.white),
          onPressed: _stopRecording,
          icon: const Icon(Icons.stop),
          label: const Text("Stop"),
        ),
      ],
    );
  }

  Widget _recordedPanel() {
    final playing = _playingUrl == _recordedPath;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          iconSize: 64,
          icon: Icon(playing ? Icons.pause_circle : Icons.play_circle,
              color: colorsConst.primary),
          onPressed: () => _toggle(_recordedPath!),
        ),
        Text("Recorded: ${_fmt(_seconds)}  (play to check before saving)",
            style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        TextField(
          controller: _titleCtr,
          decoration: const InputDecoration(
              labelText: "Title", border: OutlineInputBorder()),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
                onPressed: _saving ? null : _discard, child: const Text("Discard")),
            const SizedBox(width: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: colorsConst.primary,
                  foregroundColor: Colors.white),
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
                  : const Text("Save"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _listPanel() {
    return FutureBuilder<List<CustomerAudio>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
            child: TextButton(
                onPressed: _reload,
                child: const Text("Failed to load. Tap to retry")),
          );
        }

        final audios = List<CustomerAudio>.from(snap.data ?? []);
        audios.sort((x, y) {
          final dx = DateTime.tryParse(x.endTs.isNotEmpty ? x.endTs : x.createdTs);
          final dy = DateTime.tryParse(y.endTs.isNotEmpty ? y.endTs : y.createdTs);
          if (dx == null || dy == null) return 0;
          return dx.compareTo(dy);
        });

        if (audios.isEmpty) {
          return const Center(
              child: Text("No audio yet. Tap the mic to record."));
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: audios.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final a = audios[i];
            final playing = _playingUrl == a.url;
            final seq = i + 1;
            final ts = _fmtTs(a.endTs.isNotEmpty ? a.endTs : a.createdTs);

            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _toggle(a.url),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: playing
                      ? colorsConst.primary.withOpacity(0.08)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: playing
                        ? colorsConst.primary
                        : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: colorsConst.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        playing ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Voice Note $seq',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(Icons.access_time,
                                  size: 13, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  ts,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey.shade600),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (a.durationSec > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorsConst.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _fmtDur(a.durationSec),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorsConst.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}