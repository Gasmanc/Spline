#ifndef SPLINE_AVIF_BRIDGE_H
#define SPLINE_AVIF_BRIDGE_H

#include <stddef.h>
#include <stdint.h>

int spline_avif_decode_rgba(const uint8_t *data, size_t length, uint8_t **output, int *width, int *height);
int spline_avif_encode_rgba(const uint8_t *rgba, int width, int height, int stride, int quality, uint8_t **output, size_t *outputLength);
void spline_avif_free(void *pointer);

#endif
