import 'dart:ffi';

@Native<Double Function()>(
  symbol: 'GetHeight',
  assetId: 'package:native_height/native_height_bindings_generated.dart',
)
external double _getHeight();

class NativeHeight {
  static double getHeight() {
    return _getHeight();
  }
}