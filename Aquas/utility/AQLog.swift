//
//  AQLog.swift
//  Aquas
//
//  Created by Qiang on 2/12/15.
//  Copyright (c) 2015 gigakuma. All rights reserved.
//

import Foundation

public struct AQLog {
    static func log<T>(object: T) {
#if DEBUG
        println(object)
#endif
    }
}
