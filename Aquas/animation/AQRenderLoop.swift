//
//  AQRenderLoop.swift
//  Aquas
//
//  Created by Qiang on 2/18/15.
//  Copyright (c) 2015 gigakuma. All rights reserved.
//

import Foundation
import QuartzCore

public var AQDefaultFramePerSecond: UInt = 60

public class AQRenderLoop {
    
    private var _displayLink: CADisplayLink! = nil
    private var _lastDisplayTime: CFTimeInterval = 0
    
    private var _timeElapsed: NSTimeInterval = 0
    private var _lastTimeElapsed: NSTimeInterval = 0
    private var _timeInterval: NSTimeInterval = 0

    private var _framesDisplayed: UInt = 0
    
    private var _running: Bool = false
    private var _paused: Bool = false
    
    private var _restartTimeCounter: Bool = false
    
    private var _preferredFramePerSecond: UInt = AQDefaultFramePerSecond
    
    public var timeElapsed: NSTimeInterval { return _timeElapsed }
    public var timeInterval: NSTimeInterval { return _timeInterval }
    public var framesDisplayed: UInt { return _framesDisplayed }
    public var framePerSecond: Double {
        if _timeInterval != 0 {
            return 1.0 / _timeInterval
        } else {
            return Double.NaN
        }
    }
    
    public var preferredFramePerSecond: UInt {
        get { return _preferredFramePerSecond }
        set(fps) {
            _preferredFramePerSecond = fps == 0 ? 1 : fps
            var frameInterval: UInt = max(1, 60 / _preferredFramePerSecond)
            if _displayLink != nil {
                _displayLink.frameInterval = Int(frameInterval)
            }
        }
    }
    
    public class var mainLoop: AQRenderLoop {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var loop: AQRenderLoop! = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.loop = AQRenderLoop()
        }
        return Static.loop
    }
    
    private init() {
    }
    
    public func start() {
        if _running {
            return
        }
        var frameInteval: UInt = 60 / self.preferredFramePerSecond
        frameInteval = max(frameInteval, 1)
        _displayLink = CADisplayLink(target: self, selector: Selector("internalLoop:"))
        
        _running = true
        _restartTimeCounter = true
        _timeElapsed = 0
        _lastTimeElapsed = 0
    }
    
    public func stop() {
        if !_running {
            return
        }
        _displayLink.invalidate()
        _displayLink = nil
        _running = false
    }
    
    public func resume() {
        if !_paused {
            return
        }
        _paused = false
        _displayLink.paused = false
        _restartTimeCounter = true
    }
    
    public func pause() {
        if _paused {
            return
        }
        _paused = true
        _displayLink.paused = true
    }
    
    private func internalLoop(displayLink: CADisplayLink!) {
        ++_framesDisplayed
        self.calculateTime()
        
    }
    
    private func calculateTime() {
        if _restartTimeCounter {
            // resume or start
            _lastDisplayTime = _displayLink.timestamp
            _restartTimeCounter = false
        }
        _timeElapsed += _displayLink.timestamp - _lastDisplayTime
        _lastDisplayTime = _displayLink.timestamp
        
        _timeInterval = max(0, _timeElapsed - _lastTimeElapsed)
        _lastTimeElapsed = _timeElapsed
    #if DEBUG
        // prevent big delta time in debug mode
        if _timeInterval > 1.0 / Double(self.preferredFramePerSecond) {
            _timeInterval = 1.0 / Double(self.preferredFramePerSecond)
        }
    #endif
    }
    
}