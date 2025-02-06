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
  });

  final double height;
  final Duration protectLatency;
  final VoidCallback? startRecordHint;

  @override
  State<PhoneticButton> createState() => _PhoneticButtonState();
}

class _PhoneticButtonState extends State<PhoneticButton> {
  Timer? tapProtection;
  final recordBytes = <int>[];
  var isPress = false;
  final recorder = AudioRecorder();
  late var futurePermission = Future.value(true); //recorder.hasPermission();

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
        if (!snapshot.hasData) {
          return const CircularProgressIndicator.adaptive();
        }
        if (snapshot.data != null && snapshot.data == false) {
          return CupertinoButton.tinted(
            onPressed: () => setState(() {
              futurePermission = recorder.hasPermission();
            }),
            child: const Text('Allow microphone'),
          );
        }
        return GestureDetector(
          onTapDown: (details) {
            setState(() => isPress = true);
            tapProtection = Timer(widget.protectLatency, () async {
              final recordStream = await recorder.startStream(
                  const RecordConfig(encoder: AudioEncoder.pcm16bits));
              widget.startRecordHint?.call();
              recordBytes.clear();
              await for (final bytes in recordStream) {
                recordBytes.addAll(bytes);
              }
              //TODO: http request here
              print('finished record we got length:${recordBytes.length}');
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
                      bottom: 0, child: Text('Press to speak out word')),
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
