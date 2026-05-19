import 'dart:math';

class NativeHeight {
  static final Random _random = Random();

  static double getHeight() {
    return 0.18 + _random.nextDouble() * 0.37;
  }
}