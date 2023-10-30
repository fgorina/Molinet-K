//
//  SignalKServer.swift
//  Molinet K
//
//  Created by Francisco Gorina Vanrell on 24/10/23.
//

import Foundation
import SwiftUI
import OSLog

enum LoginState {
    case notConnected
    case connected
    case receivedHelo
    case identified
    case subscribed
}

enum WindlassState : Int {
    case Down = 1
    case Stopped = 0
    case Up = -1
    case Error = 2
    
    var description : String {
        switch(self){
        case .Down:
            return "Down"
            
        case .Stopped:
            return "Stopped"
            
        case .Up:
            return "Up"
            
        default:
            return "Error"
        }
    }
}

enum OperationState {
    case manual
    case pendura
    case fondeixar
    case levar
}

public class SignalKServer : NSObject, ObservableObject, URLSessionDelegate, URLSessionWebSocketDelegate{
    
    static var shared : SignalKServer = SignalKServer()
    
    var session : URLSession?
    
    var server : String = "ws://signalk.local:3000/signalk/v1/stream?subscribe=none"
    var wssTask  : URLSessionWebSocketTask?
    var receiveTask : Task<Int, Never>?
    var commandTask : Task<Int, Never>?
    
    var me : String = "vessels.self"
    var loginState : LoginState = .notConnected
    var token : String = ""
    
    let oneTurn =  0.056 * 7;
    let maxChain = 59.0
    let minChain = 0.0
    let penduraChain = 2.0
    let marginDepth = 1.0
    
    var operation = OperationState.manual
    
    @Published var isReceiving : Bool = false
    @Published var chain : Double = 0.0
    @Published var depth : Double = 10.0
    
    @Published var state : WindlassState = .Stopped
    
    let loginCommand =  "{\"requestId\": \"6986b469-ec48-408a-b3f5-660475208dca\", \"login\": { \"username\": \"pi\", \"password\": \"um23zap\" }}"
    
    let subscribeCommand = """
    {"context":"vessels.self",
    "subscribe": [
        {"path": "windlass.state", "policy": "instant"},
        {"path": "windlass.chain", "policy": "instant"}
    ]}
"""
    
    let updateCommand = """
{
    "token":"$T",
  "context": "vessels.self",
  "updates": [
    {
    "source":{
        "label":"Anchor K",
        "type": "signalk"
        },

      "values": [
        {
          "path": "windlass.command",
          "value": "$V"
        }
      ]
    }
  ]
}
"""
    override init(){
        super.init()
        Task{
            do {
                try connect()
            }catch{
                Logger.signalk.error("No puc connectar amb error: \(error.localizedDescription)")
            }
        }
    }
    
    func up(_ op : OperationState = .manual){
        if op == .fondeixar {
            operation = .manual
            return
        }
        
        commandTask = Task<Int, Never>{
            
            
            do {
                operation = op
                let msg = updateCommand.replacingOccurrences(of: "$V", with: "U")
                    .replacingOccurrences(of: "$T", with: self.token)
                try await sendMessage(msg)
            }catch{
                Logger.signalk.error("Error when sending up message: \(error.localizedDescription)")
                return -1
            }
            return  1
        }
    }
    
    func down(_ op : OperationState = .manual){
        
        if op == .levar {
            operation = .manual
            return
        }
        
        commandTask = Task<Int, Never>{
            do {
                operation = op
                let msg = updateCommand.replacingOccurrences(of: "$V", with: "D")
                    .replacingOccurrences(of: "$T", with: self.token)
                try await sendMessage(msg)
            }catch{
                Logger.signalk.error("Error when sending down message: \(error.localizedDescription)")
                return -1
            }
            return  1
        }
    }
    
    func stop(){
        commandTask = Task<Int, Never>{
            do {
                operation = .manual
                let msg = updateCommand.replacingOccurrences(of: "$V", with: "S")
                    .replacingOccurrences(of: "$T", with: self.token)
                try await sendMessage(msg)
            }catch{
                Logger.signalk.error("Error when sending stop message: \(error.localizedDescription)")
                return -1
            }
            return  1
        }
    }
    
    func resetChain(){
        commandTask = Task<Int, Never>{
            do {
                let msg = updateCommand.replacingOccurrences(of: "$V", with: "R")
                    .replacingOccurrences(of: "$T", with: self.token)
                try await sendMessage(msg)
            }catch{
                Logger.signalk.error("Error when sending Resetting chain message: \(error.localizedDescription)")
                return -1
            }
            return  1
        }
    }
    
    func goto(_ m : Double){
        commandTask = Task<Int, Never>{
            do {
                let command = "G\(m)"
                let msg = updateCommand.replacingOccurrences(of: "$V", with: command)
                    .replacingOccurrences(of: "$T", with: self.token)
                try await sendMessage(msg)
            }catch{
                Logger.signalk.error("Error when sending Resetting chain message: \(error.localizedDescription)")
                return -1
            }
            return  1
        }
    }
    func move(_ m : Double){        // m may be + (baixar) or - (pujar)
        commandTask = Task<Int, Never>{
            do {
                let command = "L\(m)"
                let msg = updateCommand.replacingOccurrences(of: "$V", with: command)
                    .replacingOccurrences(of: "$T", with: self.token)
                try await sendMessage(msg)
            }catch{
                Logger.signalk.error("Error when sending Resetting chain message: \(error.localizedDescription)")
                return -1
            }
            return  1
        }
    }
    
    func setMaxChain(_ m : Double){        // m may be + (baixar) or - (pujar)
        commandTask = Task<Int, Never>{
            do {
                let command = "M\(m)"
                let msg = updateCommand.replacingOccurrences(of: "$V", with: command)
                    .replacingOccurrences(of: "$T", with: self.token)
                try await sendMessage(msg)
            }catch{
                Logger.signalk.error("Error when sending setMaxChain message: \(error.localizedDescription)")
                return -1
            }
            return  1
        }
    }
    
    func calibrate(_ m : Double){        // m may be + (baixar) or - (pujar)
        commandTask = Task<Int, Never>{
            do {
                let command = "C\(m)"
                let msg = updateCommand.replacingOccurrences(of: "$V", with: command)
                    .replacingOccurrences(of: "$T", with: self.token)
                try await sendMessage(msg)
            }catch{
                Logger.signalk.error("Error when sending calibrate  message: \(error.localizedDescription)")
                return -1
            }
            return  1
        }
    }


    
    func fondeixar(){
        if chain < (depth + marginDepth) {
            goto(depth + marginDepth)
        }
    }
    
    func levar(){
        if chain > depth  {
            goto(depth - marginDepth)
        }
    }
    
    func pendura(){
        operation = .pendura
        
        goto(penduraChain)
        
    }
    
    func sendMessage(_ msg : String) async  throws {
        let wsMessage = URLSessionWebSocketTask.Message.string(msg)
        Logger.signalk.debug("Sending message: \(msg)")
        try  await wssTask?.send(wsMessage)
        
    }
    func connect() throws{
        if session == nil {
            session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            //session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        }
        
        if wssTask == nil {
            if let session = session , let url = URL(string: server){
                wssTask = session.webSocketTask(with: url)
                wssTask?.delegate = self
                wssTask?.resume()
            }
        }
        
        if receiveTask == nil {
            
            receiveTask = Task<Int, Never>{
                
                //let decoder = JSONDecoder()
                var rawMessage : String?
                self.loginState = .connected
                DispatchQueue.main.async{
                    
                    self.isReceiving = true
                }
                
                while !Task.isCancelled  {
                    
                    do {
                        let wssMessage = try await wssTask?.receive()
                        
                        switch wssMessage {
                            
                        case .data(let data):
                            
                            rawMessage = String(data: data, encoding: .utf8 )
                            
                            Logger.signalk.debug("Received message =>\(rawMessage!)")
                            
                        case .string(let str):
                            Logger.signalk.debug("Received string =>\(str)")
                            
                            do{
                                
                                switch self.loginState {
                                case .connected:
                                    let helo =  try  JSONDecoder().decode(HelloMessage.self, from: Data(str.utf8))
                                    Logger.signalk.debug("I am \(helo.me)")
                                    self.me = helo.me
                                    self.loginState = .receivedHelo
                                    try await sendMessage(loginCommand)
                                    
                                    
                                case .receivedHelo:
                                    let loginMessage = try JSONDecoder().decode(LoginMessage.self, from: Data(str.utf8))
                                    Logger.signalk.debug("Login executed, statusCode : \(loginMessage.statusCode)")
                                    Logger.signalk.debug("Token : \(loginMessage.login.token)")
                                    self.token = loginMessage.login.token
                                    self.loginState = .identified
                                    try await sendMessage(subscribeCommand)
                                    
                                    
                                case .identified:
                                    
                                    let updateMessage = try JSONDecoder().decode(UpdateMessage.self, from: Data(str.utf8))
                                    Logger.signalk.debug("Received value for \(updateMessage.updates[0].values[0].path) = \(updateMessage.updates[0].values[0].value)")
                                    
                                    switch (updateMessage.updates[0].values[0].path ){
                                    case "windlass.chain":
                                        DispatchQueue.main.async{
                                            self.chain = Double("\(updateMessage.updates[0].values[0].value)") ?? 99
                                        }
                                        /*
                                        if self.chain > self.maxChain && self.state == .Down{
                                            stop()
                                        }else if self.chain < self.oneTurn && self.state == .Up{
                                            stop()
                                        } else {
                                            
                                            
                                            switch operation {
                                            case .manual:
                                                if self.chain < 0{
                                                    stop()
                                                }
                                                
                                            case .pendura:  // Deixa l'ancla a la mida de pendura
                                                if self.state == .Down{
                                                    if self.chain > self.penduraChain{
                                                        stop()
                                                        self.operation = .manual
                                                    }
                                                } else if self.state == .Up{
                                                    if self.chain < self.penduraChain{
                                                        stop()
                                                        self.operation = .manual
                                                    }
                                                }
                                            case .fondeixar: // Baixa l'ancla fins a 1m mes que la fondaria
                                                if self.state == .Down && self.chain > (self.depth + self.marginDepth){
                                                    stop()
                                                    // Send position
                                                    self.operation = .manual
                                                }
                                            case .levar:    // Aixeca l'ancla fins a 1m menys que la fondaria
                                                if self.state == .Up && self.chain < (self.depth - self.marginDepth){
                                                    stop()
                                                    // Send position
                                                    self.operation = .manual
                                                }
                                            }
                                         }
                                         */
                                        
                                        
                                    case "windlass.state":
                                        DispatchQueue.main.async{
                                            let i = Int(updateMessage.updates[0].values[0].value)
                                            if [-1, 0, 1].firstIndex(of: i) != nil {
                                                self.state = WindlassState(rawValue: i)!
                                            }else{
                                                self.state = .Error
                                            }
                                            
                                        }
                                        
                                    default:
                                        
                                        break
                                    }
                                    
                                default:
                                    
                                    let s : String = "\(self.loginState)"
                                    Logger.signalk.error("LoginState \(s) not supported")
                                    
                                }
                            }catch{
                                Logger.signalk.error("Error \(error.localizedDescription) when decoding message \(str) ")
                            }
                            
                        default:
                            break
                            
                        }
                        
                    }catch{
                        let err = error as NSError
                        if err.domain == NSURLErrorDomain  || err.domain == NSPOSIXErrorDomain{
                            Logger.signalk.error("Signal K Conexion Error \(error)")
                            self.close()
                            
                        }else {
                            Logger.signalk.error("Signal K Error \(error) when receiving data: \(rawMessage ?? "Error in codification")")
                            
                        }
                    }
                }
                Logger.signalk.info("Exiting receiving task")
                return 1
            }
        }
        /*
         if let wssTask = wssTask {
         let message = AISSubscribeMessage(APIKey: apiKey, BoundingBoxes: [region.bbox])
         let encoder = JSONEncoder()
         let data = try encoder.encode(message)
         let str = String(data: data, encoding: .utf8)!
         let wssMessage = URLSessionWebSocketTask.Message.string(str)
         Task{
         do{
         try await wssTask.send(wssMessage)
         }catch{
         Logger.signalk.error("AIS Error \(error) when sending data")
         }
         Logger.signalk.info("Sent wellcome message")
         }
         }
         */
        
        
    }
    
    func close(){
        Logger.signalk.info("Disconnecting from server")
        receiveTask?.cancel()
        wssTask?.cancel()
        session?.finishTasksAndInvalidate()
        session = nil
        wssTask = nil
        receiveTask = nil
        DispatchQueue.main.async{
            self.isReceiving = false
        }
        
        
    }
    deinit{
        receiveTask?.cancel()
        wssTask?.cancel()
    }
    
}
