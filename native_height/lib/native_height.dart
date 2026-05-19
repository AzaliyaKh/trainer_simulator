library native_height;

// Native platforms use the C++ implementation through FFI.
// Web cannot use dart:ffi, so it uses a Dart fallback with the same API.
export 'src/native_height_stub.dart'
    if (dart.library.io) 'src/native_height_native.dart';
