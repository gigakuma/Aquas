//
//  AQAnimation.swift
//  Aquas
//
//  Created by Qiang on 2/18/15.
//  Copyright (c) 2015 gigakuma. All rights reserved.
//

import Foundation

public typealias AQAnimationFunction = (t: Double) -> Void

public typealias AQAnimationUpdateBlock = (duration: Double) -> Void

public typealias AQAnimationFinishBlock = (finished: Bool) -> Void

public enum AQAnimationState {
    case Ready
    case Playing
    case Paused
}

public class AQAnimation {
    public var duration: NSTimeInterval = 0
    public var repeatCount: UInt = 1
    public var function: AQAnimationFunction! = nil
    public var updateBlock: AQAnimationUpdateBlock! = nil
    public var finishBlock: AQAnimationFinishBlock! = nil
    
    public var state: AQAnimationState { return _state }
    public var currentTime: NSTimeInterval { return _currentTime }

    private var _state: AQAnimationState = .Ready
    private var _currentTime: NSTimeInterval = 0
    
}