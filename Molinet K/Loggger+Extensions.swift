//
//  Logger+Extensions.swift
//  ChartCalculator
//
//  Created by Francisco Gorina Vanrell on 19/7/23.
//

import OSLog

extension Logger{
    
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    static let viewCycle = Logger(subsystem: subsystem, category: "viewcycle")
    static let signalk = Logger(subsystem: subsystem, category: "signalk")
    static let other = Logger(subsystem: subsystem, category: "other")


}
