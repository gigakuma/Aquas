//
//  AQGLProgram.swift
//  Aquas
//
//  Created by Qiang on 2/12/15.
//  Copyright (c) 2015 gigakuma. All rights reserved.
//

import Foundation
import OpenGLES

public struct AQGLProgramInfo {
    let attributes: [String]!
    let uniforms: [String]!
    let vertexShader: String!
    let fragmentShader: String!
    
    init(attributes: [String]!, uniforms: [String]!, vertexShader: String!, fragmentShader: String!) {
        self.attributes = attributes
        self.uniforms = uniforms
        self.vertexShader = vertexShader
        self.fragmentShader = fragmentShader
    }
}

/// Object-oriented OpenGL program, which is responsible for creating shaders.
/// Low-level class. For the convenience of management, each program has a name.
public class AQGLProgram: AQGLObject {
    /// The name of program
    let name: String!
    
    class func create(name: String, info: AQGLProgramInfo) -> AQGLProgram? {
        var program = AQGLProgram(name, info: info)
        InternalStatic.programs[name] = program
        return program
    }
    
    class func delete(name: String) {
        var program = InternalStatic.programs[name]
        program?.release()
        InternalStatic.programs[name] = nil
    }
    
    private struct InternalStatic {
        static var programs : [String : AQGLProgram]! = [:]
    }
    
    private var _attributes: [String : GLuint]! = [:]
    private var _uniforms: [String : GLint]! = [:]
    
    private init(_ name: String!, info: AQGLProgramInfo!) {
        super.init()
        self.name = name
        // create program object
        _glID = glCreateProgram()
        // prepare shaders
        var vid: GLuint = 0, fid: GLuint = 0
        // a flag of failure of compiling shaders
        var success = true
        if success && !compileShader(&vid, GLenum(GL_VERTEX_SHADER), info.vertexShader) {
            success = false
            AQLog.log("Failed to load vertex shader: " + self.name)
        }
        if success && !compileShader(&fid, GLenum(GL_FRAGMENT_SHADER), info.fragmentShader) {
            success = false
            AQLog.log("Failed to load fragment shader: " + self.name)
        }
        // if there's error in vertex shader or fragment shader
        if !success {
            // tear down shaders and program
            if vid != 0 {
                glDeleteShader(vid)
            }
            if fid != 0 {
                glDeleteShader(fid)
            }
            glDeleteProgram(_glID)
            _glID = 0
            return
        }
        // attach shader objects to program object
        glAttachShader(_glID, vid)
        glAttachShader(_glID, fid)
        
        // bind attribut locations
        for (index, attribute) in enumerate(info.attributes) {
            _attributes[attribute as String] = GLuint(index)
        }
        
        // link program
        if !linkProgram(_glID) {
            AQLog.log("Failed to link program: " + self.name)
            // tear down program
            if _glID != 0 {
                glDeleteProgram(_glID)
                _glID = 0
            }
            // clear attributes
            _attributes.removeAll()
            return
        }
        
        // detach shaders
        if vid != 0 {
            glDetachShader(_glID, vid);
        }
        if fid != 0 {
            glDetachShader(_glID, fid);
        }
        
        // get uniform locations
        for uniform in info.uniforms {
            _uniforms[uniform as String] = glGetUniformLocation(_glID, (uniform as NSString).UTF8String)
        }
        
        // tear down shaders
        if vid != 0 {
            glDeleteShader(vid)
        }
        if fid != 0 {
            glDeleteShader(fid)
        }
    }
    
    deinit {
        release()
    }
    
    private func release() {
        // clear attributes and uniforms
        _attributes.removeAll()
        _uniforms.removeAll()
        
        // tear down program
        if _glID != 0 {
            glDeleteProgram(_glID);
            _glID = 0;
        }
    }
    
    func uniform(name: String!) -> GLint {
        if _uniforms?[name] != nil {
            return _uniforms[name]!
        } else {
            return 0
        }
    }
    
    func attribute(name: String!) -> GLuint {
        if _attributes?[name] != nil {
            return _attributes[name]!
        } else {
            return 0
        }
    }
}

func compileShader(shader: UnsafeMutablePointer<GLuint>, type: GLenum, source: String!) -> Bool {
    var string: UnsafePointer<GLchar> = (source as NSString).UTF8String
    var length: GLint = GLint((source as NSString).length)
    // create shader object
    shader.memory = glCreateShader(type)
    // binding content to shader object
    glShaderSource(shader.memory, 1, &string, &length)
    // compile shader
    glCompileShader(shader.memory);
    
    // log output
#if DEBUG
    var logLength: GLint = 0
    glGetShaderiv(shader.memory, GLenum(GL_INFO_LOG_LENGTH), &logLength)
    if logLength > 0 {
        var log: UnsafeMutablePointer<GLchar> = UnsafeMutablePointer<GLchar>(malloc(UInt(logLength)))
        glGetShaderInfoLog(shader.memory, logLength, &logLength, log)
        var str = String.fromCString(log)
        if str != nil {
            AQLog.log("Shader compiling result: " + str!)
        }
        free(log)
    }
#endif
    var status: GLint = 0
    glGetShaderiv(shader.memory, GLenum(GL_COMPILE_STATUS), &status)
    if status == 0 {
        glDeleteShader(shader.memory)
        shader.memory = 0
        return false
    }
    return true
}

func linkProgram(program: GLuint) -> Bool {
    var status: GLint = 0
    glLinkProgram(program)
#if DEBUG
    var logLength: GLint = 0
    glGetProgramiv(program, GLenum(GL_INFO_LOG_LENGTH), &logLength)
    if logLength > 0 {
        var log: UnsafeMutablePointer<GLchar> = UnsafeMutablePointer<GLchar>(malloc(UInt(logLength)))
        glGetProgramInfoLog(program, logLength, &logLength, log)
        var str = String.fromCString(log)
        if str != nil {
            AQLog.log("Program linking result: " + str!)
        }
        free(log)
    }
#endif
    glGetProgramiv(program, GLenum(GL_LINK_STATUS), &status);
    if status == 0 {
        return false;
    }
    return true;
}
