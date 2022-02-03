import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_image_utilities');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) {
      return null;
    });
  });

  tearDown(() {});
}
