import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';

import '../speech_record.dart';
import 'speak_ripple.dart';

class PhoneticButton extends StatefulWidget {
  const PhoneticButton({
    super.key,
    required this.height,
    this.startRecordHint,
    this.protectLatency = Durations.long2,
    this.doneRecord,
  });

  final double height;
  final Duration protectLatency;
  final Future<void> Function()? startRecordHint;
  final void Function(List<int> wavBytes)? doneRecord;

  @override
  State<PhoneticButton> createState() => _PhoneticButtonState();
}

class _PhoneticButtonState extends State<PhoneticButton> {
  Timer? tapProtection;
  final pcmBuffer = <int>[];
  var isPress = false;
  var recorder = AudioRecorder();
  late var futurePermission = recorder.hasPermission();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final shadowColor = CupertinoDynamicColor.withBrightness(
            color: colorScheme.secondary, darkColor: colorScheme.tertiary)
        .resolveFrom(context);
    final height = widget.height;
    return FutureBuilder(
      future: futurePermission,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == false) {
          return CupertinoButton.tinted(
            onPressed: () async {
              final isGranted = await grantMicrophonePermission();
              if (!isGranted) return;
              setState(() {
                recorder.dispose();
                recorder = AudioRecorder();
                futurePermission = recorder.hasPermission();
              });
            },
            child: const Text('Allow microphone'),
          );
        }
        return GestureDetector(
          onTapDown: (details) {
            setState(() => isPress = true);
            tapProtection = Timer(widget.protectLatency, () async {
              await widget.startRecordHint?.call();
              final recordStream = await recorder.startStream(
                  const RecordConfig(
                      encoder: AudioEncoder.pcm16bits,
                      sampleRate: kAzureSampleRate,
                      bitRate: kAzureBitRate));
              await for (final bytes in recordStream) {
                pcmBuffer.addAll(bytes);
              }
              widget.doneRecord?.call(
                  convertPcmToWav(pcmBuffer, sampleRate: kAzureSampleRate));
              pcmBuffer.clear();
            });
          },
          onTapUp: (details) {
            tapProtection?.cancel();
            recorder.isRecording().then((isRecording) {
              if (isRecording) {
                recorder.stop();
              }
              if (mounted) {
                setState(() {
                  isPress = false;
                });
              }
            });
          },
          child: AnimatedContainer(
            duration: widget.protectLatency,
            width: height * 1.82,
            height: height,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(kRadialReactionRadius),
              boxShadow: [
                if (!isPress)
                  BoxShadow(
                      color: shadowColor,
                      spreadRadius: .1,
                      blurRadius: .8,
                      offset: const Offset(0, -2)),
              ],
            ),
            child: Stack(
              alignment: const Alignment(0, 0),
              children: [
                listenerAmplitude(shadowColor, height, colorScheme),
                if (!isPress)
                  const Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: FittedBox(child: Text('Press to speak up word'))),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget listenerAmplitude(CupertinoDynamicColor shadowColor, double height,
      ColorScheme colorScheme) {
    return StreamBuilder(
        initialData: RecordState.stop,
        stream: recorder.onStateChanged(),
        builder: (context, snapshot) => AnimatedSwitcher(
              duration: widget.protectLatency * .5,
              child: snapshot.data != RecordState.record
                  ? AnimatedPhysicalModel(
                      duration: widget.protectLatency,
                      color: shadowColor,
                      animateColor: false,
                      shadowColor: shadowColor,
                      elevation: !isPress ? 4 : 1,
                      shape: BoxShape.circle,
                      child: CircleAvatar(
                        radius: height * .6 / 2,
                        // backgroundColor: colorScheme.inversePrimary,
                        child: Icon(
                          Icons.mic,
                          size: height * .4,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    )
                  : StreamBuilder(
                      initialData: .0,
                      stream: (Duration delay) async* {
                        while (await recorder.isRecording()) {
                          final ap = await recorder.getAmplitude();
                          yield (ap.current - kMinAmplitude) / -kMinAmplitude;
                          await Future.delayed(delay);
                        }
                      }(Durations.short1),
                      builder: (context, snapshot) => SpeakRipple(
                          progress: snapshot.data ?? .0, diameter: height)),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
            ));
  }

  @override
  void dispose() {
    recorder.dispose();
    super.dispose();
  }
}
