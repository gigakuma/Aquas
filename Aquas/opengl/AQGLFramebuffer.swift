//
//  AQGLFrameBuffer.swift
//  Aquas
//
//  Created by Qiang on 2/13/15.
//  Copyright (c) 2015 gigakuma. All rights reserved.
//

import Foundation
import OpenGLES

public class AQGLFramebuffer: AQGLObject {
    override init() {
        super.init()
        glGenFramebuffers(1, &_glID)
    }
    
    deinit {
        self.release()
    }
    
    public func bind() {
        if _glID != 0 {
            glBindFramebuffer(GLenum(GL_FRAMEBUFFER), _glID)
        }
    }
    
    public func attach(renderbuffer: AQGLRenderbuffer) {
        var category: AQGLRenderFormatCategory = renderbuffer.formatCategory
        if category != .None {
            self.bind()
            renderbuffer.bind()
        } else {
            return
        }
        switch category {
        case .ColorFormat:
            glFramebufferRenderbuffer(
                GLenum(GL_FRAMEBUFFER),
                GLenum(GL_COLOR_ATTACHMENT0),
                GLenum(GL_RENDERBUFFER),
                renderbuffer.glID)
        case .DepthFormat:
            glFramebufferRenderbuffer(
                GLenum(GL_FRAMEBUFFER),
                GLenum(GL_DEPTH_ATTACHMENT),
                GLenum(GL_RENDERBUFFER),
                renderbuffer.glID)
        case .StencilFormat:
            glFramebufferRenderbuffer(
                GLenum(GL_FRAMEBUFFER),
                GLenum(GL_STENCIL_ATTACHMENT),
                GLenum(GL_RENDERBUFFER),
                renderbuffer.glID)
        case .DepthStencilFormat:
            glFramebufferRenderbuffer(
                GLenum(GL_FRAMEBUFFER),
                GLenum(GL_DEPTH_STENCIL_ATTACHMENT),
                GLenum(GL_RENDERBUFFER),
                renderbuffer.glID)
        default:
            break
            // do nothing
        }
    }
    
    public func release() {
        if _glID != 0 {
            glDeleteFramebuffers(1, &_glID)
            _glID = 0
        }
    }
    
}