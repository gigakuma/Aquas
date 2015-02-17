//
//  AQGLRenderer.swift
//  Aquas
//
//  Created by Qiang on 2/17/15.
//  Copyright (c) 2015 gigakuma. All rights reserved.
//

import Foundation
import OpenGLES
import QuartzCore

public class AQGLRenderer {
    
    public var colorFormat: AQGLRenderFormat = .ColorRGBA8
    public var depthFormat: AQGLRenderFormat = .None
    public var stencilFormat: AQGLRenderFormat = .None
    public var depthStencilFormat: AQGLRenderFormat = .None
    public var multisampleMode: AQGLRenderMultisampleMode = .None
    
    public var width: Int { return Int(_width) }
    public var height: Int { return Int(_height) }
    
    private let _context: EAGLContext
    
    private let _defaultFramebuffer: AQGLFramebuffer!
    private let _colorBuffer: AQGLRenderbuffer!
    private var _depthBuffer: AQGLRenderbuffer? = nil
    private var _stencilBuffer: AQGLRenderbuffer? = nil
    private var _depthStencilBuffer: AQGLRenderbuffer? = nil
    
    private var _msaaFramebuffer: AQGLFramebuffer? = nil
    private var _msaaColorBuffer: AQGLRenderbuffer? = nil
    
    private var _width: GLint = 0
    private var _height: GLint = 0
    
    public convenience init() {
        self.init(sharegroup: nil)
    }
    
    public init(sharegroup: EAGLSharegroup?) {
        if sharegroup == nil {
            _context = EAGLContext(API: .OpenGLES3)
        } else {
            _context = EAGLContext(API: .OpenGLES3, sharegroup: sharegroup!)
        }
        
        if !EAGLContext.setCurrentContext(_context) {
            _defaultFramebuffer = nil
            _colorBuffer = nil
            return
        }
        // main framebuffer
        _defaultFramebuffer = AQGLFramebuffer()
        _colorBuffer = AQGLRenderbuffer(.ColorFormat)
        
        // bind renderbuffer to framebuffer
        _defaultFramebuffer.attach(_colorBuffer)
    }
    
    public func resizeFromLayer(layer: CAEAGLLayer) -> Bool {
        _colorBuffer.bind()
        
        if !_context.renderbufferStorage(Int(GL_RENDERBUFFER), fromDrawable: layer) {
            AQLog.log("Failed to call context")
        }
        
        glGetRenderbufferParameteriv(GLenum(GL_RENDERBUFFER), GLenum(GL_RENDERBUFFER_WIDTH), &_width)
        glGetRenderbufferParameteriv(GLenum(GL_RENDERBUFFER), GLenum(GL_RENDERBUFFER_HEIGHT), &_height)
        
        if multisampleMode != .None {
            // create msaa buffers
            if _msaaColorBuffer == nil {
                _msaaFramebuffer = AQGLFramebuffer()
                _msaaColorBuffer = AQGLRenderbuffer(.ColorFormat)
                _msaaFramebuffer?.attach(_msaaColorBuffer!)
            }
        #if DEBUG
            assert(_msaaFramebuffer?.glID != 0, "Can't create MSAA color buffer")
        #endif
            
            _msaaFramebuffer?.bind()
            _msaaColorBuffer?.bind()
            // generate storage
            _msaaColorBuffer?.generateStorage(format: colorFormat, width: _width, height: _height, multisampleMode: multisampleMode)
            
            // check status
            let status = glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER))
            if status != GLenum(GL_FRAMEBUFFER_COMPLETE) {
                AQLog.log("Failed to make complete framebuffer object \(status)")
                return false
            }
        } else {
            // release msaa color buffer
            _msaaColorBuffer?.release()
            _msaaColorBuffer = nil
            // release msaa frame buffer
            _msaaFramebuffer?.release()
            _msaaFramebuffer = nil
            
            _defaultFramebuffer.bind()
            _colorBuffer.bind()
            // generate color buffer storage
            _colorBuffer.generateStorage(format: colorFormat, width: _width, height: _height)
        }
        
        // depth buffer
        if depthFormat != .None {
            // creaete depth buffer
            if _depthBuffer == nil {
                _depthBuffer = AQGLRenderbuffer(.DepthFormat)
            #if DEBUG
                assert(_depthBuffer.glID != 0, "Can't create depth buffer")
            #endif
            }
            // generate depth buffer storage
            _depthBuffer?.bind()
            _depthBuffer?.generateStorage(format: depthFormat, width: _width, height: _height, multisampleMode: multisampleMode)
        } else {
            // release depth buffer
            _depthBuffer?.release()
            _depthBuffer = nil
        }
        
        // stencil buffer
        if stencilFormat != .None {
            // create stencil buffer
            if _stencilBuffer == nil {
                _stencilBuffer = AQGLRenderbuffer(.StencilFormat)
            #if DEBUG
                assert(_stencilBuffer.glID != 0, "Can't create stencil buffer")
            #endif
            }
            // generate stencil buffer storage
            _stencilBuffer?.bind()
            _stencilBuffer?.generateStorage(format: stencilFormat, width: _width, height: _height, multisampleMode: multisampleMode)
        } else {
            // release stencil buffer
            _stencilBuffer?.release()
            _stencilBuffer = nil
        }
        
        // depth-stencil buffer
        if depthStencilFormat != .None {
            // create d-s buffer
            if _depthStencilBuffer == nil {
                _depthStencilBuffer = AQGLRenderbuffer(.DepthStencilFormat)
            #if DEBUG
                assert(_stencilBuffer.glID != 0, "Can't create depth-stencil buffer")
            #endif
            }
            // generate d-s buffer storage
            _depthStencilBuffer?.bind()
            _depthStencilBuffer?.generateStorage(format: depthStencilFormat, width: _width, height: _height, multisampleMode: multisampleMode)
        } else {
            // release d-s buffer
            _depthStencilBuffer?.release()
            _depthStencilBuffer = nil
        }
        
        // bind color buffer
        if multisampleMode != .None {
            _msaaColorBuffer?.bind()
        } else {
            _colorBuffer.bind()
        }
        
        // check status
        let status = glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER))
        if status != GLenum(GL_FRAMEBUFFER_COMPLETE) {
            AQLog.log("Failed to make complete framebuffer object \(status)")
            return false
        }
        
        return true
    }
    
    deinit {
        _defaultFramebuffer.release()
        _colorBuffer.release()
        _depthBuffer?.release()
        _stencilBuffer?.release()
        _depthStencilBuffer?.release()
        _msaaFramebuffer?.release()
        _msaaColorBuffer?.release()
        
        if EAGLContext.currentContext() == _context {
            EAGLContext.setCurrentContext(nil)
        }
    }
    
    func swapBuffers() {
        if multisampleMode != .None {
            /* Resolve from msaaFramebuffer to resolveFramebuffer */
            glBindFramebuffer(GLenum(GL_READ_FRAMEBUFFER), _msaaFramebuffer!.glID);
            glBindFramebuffer(GLenum(GL_DRAW_FRAMEBUFFER), _defaultFramebuffer.glID);
            glResolveMultisampleFramebufferAPPLE();
        }
        
        if AQGLSupportInfo.sharedInfo.supportDiscardFramebuffer {
            var attachments: [GLenum] = []
            if multisampleMode != .None {
                attachments.append(GLenum(GL_COLOR_ATTACHMENT0))
            }
            if _depthBuffer != nil {
                attachments.append(GLenum(GL_DEPTH_ATTACHMENT))
            }
            if _stencilBuffer != nil {
                attachments.append(GLenum(GL_STENCIL_ATTACHMENT))
            }
            if _depthStencilBuffer != nil {
                attachments.append(GLenum(GL_DEPTH_STENCIL_ATTACHMENT))
            }
            // discard buffers
            var array: UnsafeMutablePointer<GLenum> =
            UnsafeMutablePointer<GLenum>(
                malloc(UInt(attachments.count * sizeof(GLenum)))
            )
            glDiscardFramebufferEXT(GLenum(GL_READ_FRAMEBUFFER), GLsizei(attachments.count), array)
            free(array)
            
            if multisampleMode != .None {
                _colorBuffer.bind()
            }
        }
        
        if !_context.presentRenderbuffer(Int(GL_RENDERBUFFER)) {
            AQLog.log("Failed to swap renderbuffer in \(__FUNCTION__)")
        }
        
        // We can safely re-bind the framebuffer here, since this will be the
        // 1st instruction of the new main loop
        if multisampleMode != .None {
            _msaaFramebuffer?.bind()
        }
    }
}