import 'dart:typed_data';

Uint8List convertPcmToWav(Iterable<int> pcmData,
    {int sampleRate = 44100, int channels = 2}) {
  int byteRate = sampleRate * channels * 2;
  int dataSize = pcmData.length;
  int fileSize = 36 + dataSize;

  ByteData header = ByteData(44);
  header.setUint32(0, 0x46464952, Endian.little); // "RIFF"
  header.setUint32(4, fileSize, Endian.little);
  header.setUint32(8, 0x45564157, Endian.little); // "WAVE"
  header.setUint32(12, 0x20746D66, Endian.little); // "fmt "
  header.setUint32(16, 16, Endian.little); // PCM header size
  header.setUint16(20, 1, Endian.little); // Format: PCM
  header.setUint16(22, channels, Endian.little);
  header.setUint32(24, sampleRate, Endian.little);
  header.setUint32(28, byteRate, Endian.little);
  header.setUint16(32, channels * 2, Endian.little);
  header.setUint16(34, 16, Endian.little); // Bits per sample
  header.setUint32(36, 0x61746164, Endian.little); // "data"
  header.setUint32(40, dataSize, Endian.little);

  return Uint8List.fromList([...header.buffer.asUint8List(), ...pcmData]);
}
