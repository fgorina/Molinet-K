//
//  HelloMessage.swift
//  Molinet K
//
//  Created by Francisco Gorina Vanrell on 25/10/23.
//

import Foundation

struct TokenInfo : Codable {
    var token: String
}
struct LoginMessage : Codable{
    var requestId : String
    var state : String
    var statusCode : Int
    var login : TokenInfo
    

}
