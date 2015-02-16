//
//  AQGLSupportInfo.swift
//  Aquas
//
//  Created by Qiang on 2/14/15.
//  Copyright (c) 2015 gigakuma. All rights reserved.
//

import Foundation
import OpenGLES

public struct AQGLSupportInfo {
    let maxTextureSize: GLint
    let maxTextureUnits: GLint
    let maxSamplesAllowd: GLint
    
    let supportNPOT: Bool
    let supportPVRTC: Bool
    let supportBGRA8: Bool
    let supportDiscardFramebuffer: Bool
    let supportShareableVAO: Bool
    
    static var sharedInfo: AQGLSupportInfo {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: AQGLSupportInfo? = nil
        }
        dispatch_once(&Static.onceToken) {
            var maxTextureSize: GLint = 0
            glGetIntegerv(GLenum(GL_MAX_TEXTURE_SIZE), &maxTextureSize);
            
            var maxTextureUnits: GLint = 0
            glGetIntegerv(GLenum(GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS), &maxTextureUnits);
            
            var maxSamplesAllowed: GLint = 0
            glGetIntegerv(GLenum(GL_MAX_SAMPLES_APPLE), &maxSamplesAllowed);
            
            let glExtenstions = UnsafePointer<CChar>(glGetString(GLenum(GL_EXTENSIONS)))
            let string = String.fromCString(glExtenstions)
            let names = string?.componentsSeparatedByString(" ")
            
            var supportPVRTC = false, supportBGRA8 = false,
                supportDiscardFramebuffer = false, supportShareableVAO = false
            if names != nil {
                supportPVRTC = contains(names!, "GL_IMG_texture_compression_pvrtc")
                supportBGRA8 = contains(names!, "GL_IMG_texture_format_BGRA8888") || contains(names!, "GL_APPLE_texture_format_BGRA8888")
                supportDiscardFramebuffer = contains(names!, "GL_EXT_discard_framebuffer")
                supportShareableVAO = contains(names!, "GL_APPLE_vertex_array_object")
            }
            
            Static.instance = AQGLSupportInfo(
                maxTextureSize: maxTextureSize,
                maxTextureUnits: maxTextureUnits,
                maxSamplesAllowd: maxSamplesAllowed,
                supportNPOT: true,
                supportPVRTC: supportPVRTC,
                supportBGRA8: supportBGRA8,
                supportDiscardFramebuffer: supportDiscardFramebuffer,
                supportShareableVAO: supportShareableVAO)
        }
        return Static.instance!
    }
}