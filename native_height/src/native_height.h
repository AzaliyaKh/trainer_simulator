#pragma once

#if defined(_WIN32)
#define FFI_EXPORT __declspec(dllexport)
#else
#define FFI_EXPORT __attribute__((visibility("default"))) __attribute__((used))
#endif

#ifdef __cplusplus
extern "C" {
#endif

FFI_EXPORT double GetHeight(void);

#ifdef __cplusplus
}
#endif
