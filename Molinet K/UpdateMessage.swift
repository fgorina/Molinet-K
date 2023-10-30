//
//  UpdateMessage.swift
//  Molinet K
//
//  Created by Francisco Gorina Vanrell on 25/10/23.
//
import Foundation

struct ValueInfo : Codable {
    var path: String
    var value : Double
}

struct UpdateInfo : Codable {
    var values : [ValueInfo]
}
struct UpdateMessage : Codable{
    var context : String
    var updates : [UpdateInfo]
}
