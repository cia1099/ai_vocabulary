library speech_record;

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path/path.dart' as p;

class RecordSpeechButton extends StatefulWidget {
  final Widget child;
  final String appDirectory;
  final Duration protectLatency;
  final String Function() createWavFileName;
  final VoidCallback? startRecordHint;
  final void Function(String? outputPath) doneRecord;
  final ShapeBorder? blinkShape;

  const RecordSpeechButton({
    super.key,
    required this.appDirectory,
    this.protectLatency = Durations.long2,
    required this.createWavFileName,
    required this.doneRecord,
    required this.child,
    this.startRecordHint,
    this.blinkShape,
  });

  @override
  State<RecordSpeechButton> createState() => _RecordSpeechButtonState();
}

class _RecordSpeechButtonState extends State<RecordSpeechButton> {
  StreamSubscription? tapProtection;
  final record = AudioRecorder();
  late var futurePermission = Future.value(true); //record.hasPermission();

  @override
  void initState() {
    super.initState();
    final audioDir = Directory(p.join(widget.appDirectory, 'audio'));
    if (!audioDir.existsSync()) audioDir.createSync();
  }

  @override
  void dispose() {
    record.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: FutureBuilder(
        future: futurePermission,
        builder: (context, snapshot) => InkWell(
          customBorder: widget.blinkShape,
          onDoubleTap: snapshot.data == true
              ? null
              : () => setState(() {
                    futurePermission = record.hasPermission();
                  }),
          onTapDown: snapshot.data == true
              ? (_) {
                  tapProtection = Stream.periodic(widget.protectLatency, null)
                      .take(1)
                      .listen(
                    null,
                    onDone: () async {
                      final filename = widget.createWavFileName();
                      final audioDir = p.join(widget.appDirectory, 'audio');
                      await record.start(
                          const RecordConfig(encoder: AudioEncoder.wav),
                          path: p.join(audioDir, filename));
                      widget.startRecordHint?.call();
                    },
                  );
                }
              : null,
          onTapUp: snapshot.data == true
              ? (_) {
                  tapProtection?.cancel();
                  record.isRecording().then((isRecording) {
                    if (isRecording) {
                      record.stop().then(widget.doneRecord);
                    } else {
                      widget.doneRecord(null);
                    }
                  });
                }
              : null,
          child: AbsorbPointer(
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
