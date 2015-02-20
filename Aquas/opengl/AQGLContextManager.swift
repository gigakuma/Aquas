//
//  AQGLContextManager.swift
//  Aquas
//
//  Created by Qiang on 2/18/15.
//  Copyright (c) 2015 gigakuma. All rights reserved.
//

import Foundation
import OpenGLES

public class AQGLContextManager {
    
    private struct InternalStatic {
        static var contexts : [String : EAGLContext] = [:]
        static let lock: NSLock = NSLock()
        static var sharegroup: EAGLSharegroup? = nil
    }
    
    public typealias AQGLContextBlock = () -> Void
    
    public class func addContext(context: EAGLContext!, identifier: String) -> Bool {
        if let ctx = InternalStatic.contexts[identifier] {
            return false
        }
        if InternalStatic.sharegroup == nil {
            InternalStatic.sharegroup = context.sharegroup
        }
        InternalStatic.contexts[identifier] = context
        return true
    }
    
    public class func removeContext(identifier: String) -> Bool {
        if let ctx = InternalStatic.contexts[identifier] {
            InternalStatic.contexts[identifier] = nil
            if InternalStatic.contexts.count == 0 {
                InternalStatic.sharegroup = nil
            }
            return true
        }
        return false
    }
    
    class var sharegroup: EAGLSharegroup? { return InternalStatic.sharegroup }
    
    public class func beginContext(identifier: String) {
        let context = InternalStatic.contexts[identifier]
        if context != nil {
            InternalStatic.lock.lock()
            EAGLContext.setCurrentContext(context)
        }
    }
    
    public class func endContext() {
        InternalStatic.lock.unlock()
    }
    
    public class func runInContext(identifier: String, block: AQGLContextBlock) {
        AQGLContextManager.beginContext(identifier)
        block()
        AQGLContextManager.endContext()
    }
}