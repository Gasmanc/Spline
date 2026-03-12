#ifndef SPLINE_WEBP_BRIDGE_H
#define SPLINE_WEBP_BRIDGE_H

#include <stddef.h>
#include <stdint.h>

int spline_webp_decode_rgba(const uint8_t *data, size_t length, uint8_t **output, int *width, int *height);
int spline_webp_encode_rgba(const uint8_t *rgba, int width, int height, int stride, float quality, uint8_t **output, size_t *outputLength);
void spline_webp_free(void *pointer);

#endif
