#include "bridge.h"
#include <stdlib.h>

#if defined(__APPLE__)
#include <TargetConditionals.h>
#else
#define TARGET_OS_OSX 0
#endif

#if TARGET_OS_OSX
#include <webp/decode.h>
#include <webp/encode.h>
#endif

int spline_webp_decode_rgba(const uint8_t *data, size_t length, uint8_t **output, int *width, int *height) {
#if TARGET_OS_OSX
    if ((data == NULL) || (output == NULL) || (width == NULL) || (height == NULL)) {
        return 0;
    }

    int imageWidth = 0;
    int imageHeight = 0;
    if (!WebPGetInfo(data, length, &imageWidth, &imageHeight)) {
        return 0;
    }

    uint8_t *decoded = WebPDecodeRGBA(data, length, &imageWidth, &imageHeight);
    if (decoded == NULL) {
        return 0;
    }

    *output = decoded;
    *width = imageWidth;
    *height = imageHeight;
    return 1;
#else
    (void)data;
    (void)length;
    (void)output;
    (void)width;
    (void)height;
    return 0;
#endif
}

int spline_webp_encode_rgba(const uint8_t *rgba, int width, int height, int stride, float quality, uint8_t **output, size_t *outputLength) {
#if TARGET_OS_OSX
    if ((rgba == NULL) || (output == NULL) || (outputLength == NULL)) {
        return 0;
    }

    uint8_t *encoded = NULL;
    size_t encodedLength = WebPEncodeRGBA(rgba, width, height, stride, quality, &encoded);
    if ((encoded == NULL) || (encodedLength == 0)) {
        return 0;
    }

    *output = encoded;
    *outputLength = encodedLength;
    return 1;
#else
    (void)rgba;
    (void)width;
    (void)height;
    (void)stride;
    (void)quality;
    (void)output;
    (void)outputLength;
    return 0;
#endif
}

void spline_webp_free(void *pointer) {
#if TARGET_OS_OSX
    if (pointer != NULL) {
        WebPFree(pointer);
    }
#else
    if (pointer != NULL) {
        free(pointer);
    }
#endif
}
