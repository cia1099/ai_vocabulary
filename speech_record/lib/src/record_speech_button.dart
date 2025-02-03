import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path/path.dart' as p;

import '../speech_record.dart';

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
                  tapProtection =
                      Stream.periodic(widget.protectLatency).take(1).listen(
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
            child: StreamBuilder(
                stream: record.onStateChanged(),
                builder: (context, snapshot) => AnimatedSwitcher(
                      duration: Durations.short2,
                      child: snapshot.data != RecordState.record
                          ? widget.child
                          : ConstrainedBox(
                              constraints: const BoxConstraints(
                                  minHeight: kMinInteractiveDimension,
                                  minWidth: double.infinity),
                              child: amplitudeListener(),
                            ),
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                    )),
          ),
        ),
      ),
    );
  }

  StreamBuilder<double> amplitudeListener() {
    final colorScheme = Theme.of(context).colorScheme;
    final colors = [
      colorScheme.primary.withValues(alpha: 16 / 255),
      colorScheme.primary.withValues(alpha: (16 * 4 + 13) / 255),
      colorScheme.primary.withValues(alpha: 16 * 10 / 255),
      colorScheme.primary.withValues(alpha: (16 * 4 + 13) / 255),
      colorScheme.primary.withValues(alpha: 32 / 255),
    ];
    const stops = [0.0, 0.09, 0.51, 0.93, 1.0];
    return StreamBuilder(
        initialData: kMinAmplitude,
        stream: (Duration delay) async* {
          while (await record.isRecording()) {
            final ap = await record.getAmplitude();
            yield ap.current;
            await Future.delayed(delay);
          }
        }(Durations.short1),
        builder: (context, snapshot) {
          final ap = snapshot.data ?? kMinAmplitude;
          final radius =
              ((ap.clamp(kMinAmplitude, kMaxAmplitude) - kMinAmplitude) /
                      -kMinAmplitude)
                  .clamp(.0, 1.0);
          return ShaderMask(
            shaderCallback: (bounds) => RadialGradient(
              radius: radius,
              colors: colors,
              stops: stops,
            ).createShader(bounds),
            child: const Icon(
              CupertinoIcons.dot_radiowaves_left_right,
              size: kMinInteractiveDimensionCupertino,
            ),
          );
        });
  }
}
