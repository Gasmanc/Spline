#include "bridge.h"
#include <stdlib.h>
#include <string.h>

#if defined(__APPLE__)
#include <TargetConditionals.h>
#else
#define TARGET_OS_OSX 0
#endif

#if TARGET_OS_OSX
#include <avif/avif.h>
#endif

int spline_avif_decode_rgba(const uint8_t *data, size_t length, uint8_t **output, int *width, int *height) {
#if TARGET_OS_OSX
    if ((data == NULL) || (output == NULL) || (width == NULL) || (height == NULL)) {
        return 0;
    }

    avifDecoder *decoder = avifDecoderCreate();
    if (decoder == NULL) {
        return 0;
    }

    avifResult parseResult = avifDecoderSetIOMemory(decoder, data, length);
    if (parseResult != AVIF_RESULT_OK) {
        avifDecoderDestroy(decoder);
        return 0;
    }

    parseResult = avifDecoderParse(decoder);
    if (parseResult != AVIF_RESULT_OK) {
        avifDecoderDestroy(decoder);
        return 0;
    }

    parseResult = avifDecoderNextImage(decoder);
    if (parseResult != AVIF_RESULT_OK) {
        avifDecoderDestroy(decoder);
        return 0;
    }

    avifRGBImage rgb;
    avifRGBImageSetDefaults(&rgb, decoder->image);
    rgb.format = AVIF_RGB_FORMAT_RGBA;
    rgb.depth = 8;
    avifRGBImageAllocatePixels(&rgb);

    avifResult convertResult = avifImageYUVToRGB(decoder->image, &rgb);
    if (convertResult != AVIF_RESULT_OK) {
        avifRGBImageFreePixels(&rgb);
        avifDecoderDestroy(decoder);
        return 0;
    }

    size_t size = rgb.rowBytes * rgb.height;
    uint8_t *buffer = (uint8_t *)malloc(size);
    if (buffer == NULL) {
        avifRGBImageFreePixels(&rgb);
        avifDecoderDestroy(decoder);
        return 0;
    }

    memcpy(buffer, rgb.pixels, size);
    *output = buffer;
    *width = rgb.width;
    *height = rgb.height;

    avifRGBImageFreePixels(&rgb);
    avifDecoderDestroy(decoder);
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

int spline_avif_encode_rgba(const uint8_t *rgba, int width, int height, int stride, int quality, uint8_t **output, size_t *outputLength) {
#if TARGET_OS_OSX
    if ((rgba == NULL) || (output == NULL) || (outputLength == NULL)) {
        return 0;
    }

    avifImage *image = avifImageCreate(width, height, 8, AVIF_PIXEL_FORMAT_YUV444);
    if (image == NULL) {
        return 0;
    }

    avifRGBImage rgb;
    avifRGBImageSetDefaults(&rgb, image);
    rgb.format = AVIF_RGB_FORMAT_RGBA;
    rgb.depth = 8;
    rgb.pixels = (uint8_t *)rgba;
    rgb.rowBytes = stride;

    avifResult rgbResult = avifImageRGBToYUV(image, &rgb);
    if (rgbResult != AVIF_RESULT_OK) {
        avifImageDestroy(image);
        return 0;
    }

    avifEncoder *encoder = avifEncoderCreate();
    if (encoder == NULL) {
        avifImageDestroy(image);
        return 0;
    }

    int clamped = quality;
    if (clamped < 1) {
        clamped = 1;
    }
    if (clamped > 100) {
        clamped = 100;
    }

    int quantizer = 63 - (int)((double)clamped * 0.63);
    if (quantizer < 0) {
        quantizer = 0;
    }
    if (quantizer > 63) {
        quantizer = 63;
    }

    encoder->minQuantizer = quantizer;
    encoder->maxQuantizer = quantizer;
    encoder->maxThreads = 1;

    avifRWData avifOutput = AVIF_DATA_EMPTY;
    avifResult writeResult = avifEncoderWrite(encoder, image, &avifOutput);
    if (writeResult != AVIF_RESULT_OK) {
        avifEncoderDestroy(encoder);
        avifImageDestroy(image);
        return 0;
    }

    uint8_t *buffer = (uint8_t *)malloc(avifOutput.size);
    if (buffer == NULL) {
        avifRWDataFree(&avifOutput);
        avifEncoderDestroy(encoder);
        avifImageDestroy(image);
        return 0;
    }

    memcpy(buffer, avifOutput.data, avifOutput.size);
    *output = buffer;
    *outputLength = avifOutput.size;

    avifRWDataFree(&avifOutput);
    avifEncoderDestroy(encoder);
    avifImageDestroy(image);
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

void spline_avif_free(void *pointer) {
    if (pointer != NULL) {
        free(pointer);
    }
}
