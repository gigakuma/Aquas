//
//  AQGLRenderBuffer.swift
//  Aquas
//
//  Created by Qiang on 2/13/15.
//  Copyright (c) 2015 gigakuma. All rights reserved.
//

import Foundation
import OpenGLES

public enum AQGLRenderFormatCategory {
    case None
    case ColorFormat
    case DepthFormat
    case StencilFormat
    case DepthStencilFormat
}

public enum AQGLRenderFormat {
    case None
    
    case ColorRGBA8
    case ColorRGB565
    case ColorRGBA4
    
    case Depth16
    case Depth24
    case Depth32F
    
    case Stencil8
    
    case Depth24_Stencil8
    case Depth32F_Stencil8
    
    public var category: AQGLRenderFormatCategory {
        switch self {
        case .ColorRGBA8, .ColorRGB565, .ColorRGBA4:
            return .ColorFormat
        case .Depth16, .Depth24, .Depth32F:
            return .DepthFormat
        case .Stencil8:
            return .StencilFormat
        case .Depth24_Stencil8, .Depth32F_Stencil8:
            return .DepthStencilFormat
        default:
            return .None
        }
    }
    
    var internalFormat: GLenum {
        switch self {
        case .None:
            return 0
            
        case .ColorRGBA8:
            return GLenum(GL_RGBA8)
        case .ColorRGB565:
            return GLenum(GL_RGB565)
        case .ColorRGBA4:
            return GLenum(GL_RGBA4)
            
        case .Depth16:
            return GLenum(GL_DEPTH_COMPONENT16)
        case .Depth24:
            return GLenum(GL_DEPTH_COMPONENT24)
        case .Depth32F:
            return GLenum(GL_DEPTH_COMPONENT32F)
            
        case .Stencil8:
            return GLenum(GL_STENCIL_INDEX8)
            
        case .Depth24_Stencil8:
            return GLenum(GL_DEPTH24_STENCIL8)
        case .Depth32F_Stencil8:
            return GLenum(GL_DEPTH32F_STENCIL8)
        }
    }
}

public enum AQGLRenderMultisampleMode : Int {
    case None = 0
    case Sample4X = 4
}

public class AQGLRenderbuffer : AQGLObject {
    
    public let formatCategory: AQGLRenderFormatCategory
    var format: AQGLRenderFormat = .None
    var multisampleMode: AQGLRenderMultisampleMode = .None
    var width: GLsizei = 0
    var height: GLsizei = 0
    
    public init(_ formatCategory: AQGLRenderFormatCategory) {
        self.formatCategory = formatCategory
        super.init()
        // create render buffer object
        glGenRenderbuffers(1, &_glID)
    }
    
    deinit {
        self.release()
    }
    
    public func generateStorage(#format: AQGLRenderFormat, width: GLsizei, height: GLsizei, multisampleMode: AQGLRenderMultisampleMode = .None) {
        // format and category are not match
        if format != .None && format.category != formatCategory {
            return
        }
        self.format = format
        self.multisampleMode = multisampleMode
        self.width = width
        self.height = height
        
        // not generate with none format
        if format == .None {
            return
        }
        // generate buffer
        if self.multisampleMode != .None {
            glRenderbufferStorageMultisampleAPPLE(
                GLenum(GL_RENDERBUFFER),
                GLsizei(self.multisampleMode.rawValue),
                self.format.internalFormat,
                self.width, self.height)
        } else {
            glRenderbufferStorage(
                GLenum(GL_RENDERBUFFER),
                self.format.internalFormat,
                self.width, self.height)
        }
    }
    
    public func bind() {
        if _glID != 0 {
            glBindRenderbuffer(GLenum(GL_RENDERBUFFER), _glID)
        }
    }
    
    public func release() {
        if _glID != 0 {
            glDeleteRenderbuffers(1, &_glID)
            _glID = 0
        }
    }
    
}
