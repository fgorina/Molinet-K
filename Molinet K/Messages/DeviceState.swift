//
//  DeviceState.swift
//  Molinet K
//
//  Created by Francisco Gorina Vanrell on 1/12/23.
//

import Foundation
enum WSState : Int {
    case disconnected = 0
    case connected = -1
    case hello = 1
    case identified = 2
    
    var stringValue : String {
        switch(self){
            
        case .disconnected :
            "∅"
            
        case .hello:
            "👋"
        
        case .connected:
            "🔗"
            
        case .identified:
            "K"
            
        }
    }
}

struct DeviceState {
    
    var deviceName : String
    var ssid : String
    var password : String
    var host : String
    var port : Int
    var path : String
    var mmPulse : Double
    var lChain : Double
    var isUp : Int
    var isDown : Int
    var wsState : WSState
    
    
    init(_ data : String){
        
        let rows = data.split(separator: "\n")
        
        if rows.count >= 11 {
            mmPulse = Double(rows[0]) ?? 1.0
            lChain = Double(rows[1]) ?? 0.0
            ssid = String(rows[2])
            password = String(rows[3])
            deviceName = String(rows[4])
            host = String(rows[5])
            port = Int(rows[6]) ?? 3000
            path = String(rows[7])
            isUp = Int(rows[8]) ?? 0
            isDown = Int(rows[9]) ?? 0
            wsState = WSState(rawValue: Int(rows[10]) ?? 0) ?? .disconnected
            
            
            
        }else{
            mmPulse =  1.0
            lChain =  0.0
            ssid = ""
            password = ""
            deviceName = ""
            host = ""
            port = 3000
            path = ""
            isUp = 0
            isDown = 0
            wsState = .disconnected
        }
        
        
    }
    
    
}
