//
//  AQGLDataConvert.c
//  Aquas
//
//  Created by Qiang on 2/16/15.
//  Copyright (c) 2015 gigakuma. All rights reserved.
//

#include <stdio.h>

// convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRRRRRGGGGGGGGBBBBBBBB"
void aq_convert_RGBA8_RGB8(const void *input, void *output, unsigned int width, unsigned int height) {
    unsigned char *inPixel8 = (unsigned char *)input;
    unsigned char *outPixel8 = (unsigned char *)output;
    for (int i = 0; i < width * height; ++i) {
        *outPixel8++ = *inPixel8++; // red
        *outPixel8++ = *inPixel8++; // green
        *outPixel8++ = *inPixel8++; // blue
        inPixel8++; // skip alpha
    }
}

// convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRGGGGGGBBBBB"
void aq_convert_RGBA8_RGB565(const void *input, void *output, unsigned int width, unsigned int height) {
    unsigned int *inPixel32 = (unsigned int *)input;
    unsigned short *outPixel16 = (unsigned short *)output;
    for (int i = 0; i < width * height; ++i, ++inPixel32)
        *outPixel16++ =
        ((((*inPixel32 >> 0) & 0xFF) >> 3) << 11) |
        ((((*inPixel32 >> 8) & 0xFF) >> 2) << 5) |
        ((((*inPixel32 >> 16) & 0xFF) >> 3) << 0);
}

// convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRGGGGBBBBAAAA"
void aq_convert_RGBA8_RGBA4(const void *input, void *output, unsigned int width, unsigned int height) {
    unsigned int *inPixel32 = (unsigned int *)input;
    unsigned short *outPixel16 = (unsigned short *)output;
    for (int i = 0; i < width * height; ++i, ++inPixel32)
        *outPixel16++ =
        ((((*inPixel32 >> 0) & 0xFF) >> 4) << 12) |
        ((((*inPixel32 >> 8) & 0xFF) >> 4) << 8) |
        ((((*inPixel32 >> 16) & 0xFF) >> 4) << 4) |
        ((((*inPixel32 >> 24) & 0xFF) >> 4) << 0);
}

// convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "LLLLLLLLAAAAAAAA"
void aq_convert_RGBA8_LA88(const void *input, void *output, unsigned int width, unsigned int height) {
    unsigned char *inPixel8 = (unsigned char *)input;
    unsigned char *outPixel8 = (unsigned char *)output;
    for (int i = 0; i < width * height; ++i) {
        float l = 0.2126f * inPixel8[0] + 0.7152f * inPixel8[1] + 0.0722f * inPixel8[2];
        inPixel8 += 3;
        *outPixel8++ = (unsigned char) l;
        //      *outPixel8++ = *inPixel8++;
        //      inPixel8 += 2;
        *outPixel8++ = *inPixel8++;
    }
}

// convert "RRRRRGGGGGBBBBB" to "RRRRRGGGGGBBBBBA"
void aq_convert_RGB565_RGBA5551(const void *input, void *output, unsigned int width, unsigned int height) {
    unsigned short *inPixel16 = (unsigned short *)input;
    unsigned short *outPixel16 = (unsigned short *)output;
    for (int i = 0; i < width * height; ++i, ++outPixel16, ++inPixel16)
        *outPixel16 = *inPixel16 << 1 | 0x0001;
}