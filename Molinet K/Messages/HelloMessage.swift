//
//  HelloMessage.swift
//  Molinet K
//
//  Created by Francisco Gorina Vanrell on 25/10/23.
//

import Foundation

struct HelloMessage : Codable{
    var name : String
    var version : String
    var me : String
    
    enum CodingKeys: String, CodingKey{
        case name = "name"
        case version = "version"
        case me = "self"
       
    }

}
