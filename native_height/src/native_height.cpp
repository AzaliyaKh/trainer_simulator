#include "native_height.h"

#include <random>

extern "C" FFI_EXPORT double GetHeight(void) {
    static std::random_device random_device;
    static std::mt19937 generator(random_device());
    static std::uniform_real_distribution<double> distribution(0.18, 0.55);

    return distribution(generator);
}
