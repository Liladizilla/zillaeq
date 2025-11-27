import 'dart:convert';
import 'dart:io';

void main() async {
  // Tiny 1x1 transparent PNG
  const b64 = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII=';
  final bytes = base64Decode(b64);
    final out = File(r'assets\WhatsApp Image 2025-10-17 at 2.16.33 PM.jpeg');
  await out.create(recursive: true);
  await out.writeAsBytes(bytes);
  // Use stdout to avoid analyzer warning about print usage in production code.
  stdout.writeln('Wrote assets/logo.png (${bytes.length} bytes)');
}
