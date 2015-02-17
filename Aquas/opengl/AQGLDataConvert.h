//
//  AQGLDataConvert.h
//  Aquas
//
//  Created by Qiang on 2/16/15.
//  Copyright (c) 2015 gigakuma. All rights reserved.
//

#ifndef __Aquas__AQGLDataConvert__
#define __Aquas__AQGLDataConvert__

#include <stdio.h>

void aq_convert_RGBA8_RGB8(const void *input, void *output, unsigned int width, unsigned int height);
void aq_convert_RGBA8_RGB565(const void *input, void *output, unsigned int width, unsigned int height);
void aq_convert_RGBA8_RGBA4(const void *input, void *output, unsigned int width, unsigned int height);
void aq_convert_RGBA8_LA88(const void *input, void *output, unsigned int width, unsigned int height);

void aq_convert_RGB565_RGBA5551(const void *input, void *output, unsigned int width, unsigned int height);

#endif /* defined(__Aquas__AQGLDataConvert__) */
