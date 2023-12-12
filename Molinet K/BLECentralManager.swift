//
//  File.swift
//  Molinet K
//
//  Created by Francisco Gorina Vanrell on 30/11/23.
//


import Foundation

import CoreBluetooth

enum OperationState {
    case manual
    case pendura
    case fondeixar
    case levar
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
    
    init(_ c : Character){
        switch(c){
        case "U":
            self = .Up
            
        case "D":
            self = .Down
            
        case "S":
            self = .Stopped
            
        default:
            self = .Error
        }
    }
}

enum BLEState : String {
    case on = "On"
    case off = "Off"
    case disconnected = "Disc"
    case scanning = "Scan"
    case connecting = "Cing"
    case connected = "Cted"
}
class BLECentralManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, ObservableObject {
    
    
    static var shared : BLECentralManager = BLECentralManager()

    // MARK: - Properties
    
    private var centralManager: CBCentralManager!
    private var connectedPeripheral: CBPeripheral?
    private var commandCharacteristic: CBCharacteristic?
    private var windlassStateCharacteristic: CBCharacteristic?
    
    private let penduraChain = 1.0
    private let marginDepth = 1.0
    
    public var operation = OperationState.manual
    public var deviceState : DeviceState = DeviceState("")

    @Published var connectionState : BLEState = .off
    @Published var chain : Double = 0.0
    @Published var depth : Double = 0.0
    @Published var state : WindlassState = .Stopped
    // Add other properties as needed
    
    
    private let serviceUUID = CBUUID(string: "c7622328-de83-4c4d-957e-b8d51309194b")
    private let commandUUID = CBUUID(string: "7aa080fe-0ef8-4f0c-987f-74a636dd3a77")
    private let stateUUID = CBUUID(string: "f5c63a4c-553a-4b9f-8ece-3ebcd4da2f07")
    
    #if os(iOS)
    private var signalkServer : SignalKServer?
    #endif
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        print("Creating CentralManager")
    }
    
    // MARK: - CBCentralManagerDelegate Methods
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            // Bluetooth is powered on, start scanning for peripherals
            print("Bluetooth powered ON")
            DispatchQueue.main.async {
                self.connectionState = .on
            }
            startScanning()
        case .poweredOff:
            // Bluetooth is powered off
            DispatchQueue.main.async {
                self.connectionState = .off
            }
            print("Bluetooth is powered off.")
            // Handle the situation accordingly
        default:
            print("BLE Central State \(central.state)")
            break
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Called when a peripheral is discovered during scanning
        // You can filter peripherals based on your requirements and connect to the desired one
        
        print("Found \(peripheral.name ?? "" )")
        if peripheral.name == "windlass" || true{       //TODO: Substitute with parameter
            DispatchQueue.main.async {
                self.connectionState = .connecting
            }
            connectedPeripheral = peripheral
            connectToPeripheral(peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // Called when a connection to a peripheral is successful
        connectedPeripheral = peripheral
        connectedPeripheral?.delegate = self
        
        // Discover services and characteristics of the connected peripheral
        connectedPeripheral?.discoverServices(nil)
        
        print("Connected to peripheral: \(peripheral)")
    }
    
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, timestamp: CFAbsoluteTime, isReconnecting: Bool, error: Error?) {
        
        print("Disconnected from  peripheral: \(peripheral)")
        DispatchQueue.main.async {
            self.connectionState = .disconnected
        }
        
    }
    // MARK: - CBPeripheralDelegate Methods
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        
        // Discover characteristics for each service
        if let services = peripheral.services {
            for service in services {
                if service.uuid == serviceUUID{
                    print("Discovered service: \(service.uuid.uuidString)")
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else {
            print("Error discovering characteristics: \(error!.localizedDescription)")
            return
        }
        
        // Check for the characteristics you need
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                print("Discovered characteristic: \(characteristic.uuid.uuidString)")
                if characteristic.uuid == commandUUID {
                    commandCharacteristic = characteristic
                } else if characteristic.uuid == stateUUID {
                    windlassStateCharacteristic = characteristic
                    // Enable notifications for the read/notify characteristic
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
            
            if commandCharacteristic != nil && windlassStateCharacteristic != nil {
                print("Now connected to device")
                writeValueToCommandCharacteristic("I")
                DispatchQueue.main.async {
                    self.connectionState = .connected
                }
            }
        }
        
        // You can perform additional actions here if needed
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // Called when the value of a characteristic is updated (e.g., for read/notify characteristics)
        if characteristic.uuid == windlassStateCharacteristic?.uuid {
            if let value = characteristic.value {
                if let svalue = String(data: value, encoding: .utf8){
                    
                    if let c = svalue.first{
                        if c == "I" {
                            let rest = String(svalue[svalue.index(svalue.startIndex, offsetBy: 1)...])
                            deviceState = DeviceState(rest)
                            
                            // Start new server if possible
                            #if os(iOS)
                            if let sk = signalkServer  {
                                do {
                                    try sk.connect()
                                }catch{
                                    
                                }
                            }else{
                                signalkServer = SignalKServer(host: deviceState.host, port: deviceState.port, path: deviceState.path)
                            }

                            #endif
                        }
                        else{
                            DispatchQueue.main.async{
                                self.state = WindlassState(c)
                                self.chain = Double(svalue[svalue.index(svalue.startIndex, offsetBy: 1)...]) ?? 0.0
                                
                                if self.state == .Stopped || self.state == .Error {
                                    self.operation = .manual
                                }
                            }
                        }
                    }
                }
                
                // Process the received value
                print("Received value for WindlassStateCharacteristic: \(value)")
            }
        }
    }
    
    
    // MARK: - Public Methods
    
    func startScanning() {
        // Start scanning for BLE peripherals
        print("Starting scan for srvices \(serviceUUID.uuidString)")
        centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
        DispatchQueue.main.async {
            self.connectionState = .scanning
        }
    }
    
    func stopScanning() {
        // Stop scanning for BLE peripherals
        print("Stop Scanning")
        centralManager.stopScan()
    }
    
    func connectToPeripheral(_ peripheral: CBPeripheral) {
        // Connect to the specified peripheral
        print("Connecting to peripheral \(peripheral.name ?? "")")
        centralManager.connect(peripheral, options: nil)
    }
    
    func writeValueToCommandCharacteristic(_ value: String) {
        
        if let data = value.data(using: .utf8){
            // Check if the commandCharacteristic is valid and connectedPeripheral is set
            guard let commandChar = commandCharacteristic, let peripheral = connectedPeripheral else {
                print("Invalid command characteristic or not connected to a peripheral.")
                return
            }
            
            // Write the value to the write-only characteristic
            peripheral.writeValue(data, for: commandChar, type: .withResponse)
        }
        
    }
    func connect(){
         
        if let peripheral = connectedPeripheral {
            connectToPeripheral(peripheral)
        }else{
            if centralManager.state == .poweredOn{
                startScanning()
            }
        }
    }
    
    func close(){
        
        if let peripheral = connectedPeripheral, peripheral.state == .connected {
            centralManager.cancelPeripheralConnection(peripheral)
            
            #if os(iOS)
            if let sk = signalkServer {
                sk.close()
            }
            #endif
        }
    }

    // Add other methods as needed
    
}

extension BLECentralManager {
    

    func up(){
        writeValueToCommandCharacteristic("U")
    }
    
    func down(){
        writeValueToCommandCharacteristic("D")
    }
    
    func stop(){
        writeValueToCommandCharacteristic("S")
    }
    
    func resetChain(){
        writeValueToCommandCharacteristic("R")
    }
    
    func goto(_ m : Double){
        writeValueToCommandCharacteristic("G\(m)")
    }
    
    func move(_ m : Double){
        writeValueToCommandCharacteristic("L\(m)")
    }
    
    func setMaxChain(_ m : Double){
        writeValueToCommandCharacteristic("M\(m)")
    }
    
    func calibrate(_ m : Double){
        writeValueToCommandCharacteristic("C\(m)")
    }
    
    func setSSID(_ ssid : String){
        writeValueToCommandCharacteristic("N\(ssid)")
    }
    
    func setPassword(_ pwd : String){
        writeValueToCommandCharacteristic("P\(pwd)")
    }
    
    func setDeviceName(_ name : String){
        writeValueToCommandCharacteristic("J\(name)")
    }
    
    func setSignalKServer(ip : String = "10.10.10.1" , port: Int = 3000, path: String = "/signalk/v1/stream?subscribe=none"){
        writeValueToCommandCharacteristic("KI\(ip)")
        writeValueToCommandCharacteristic("KP\(port)")
        writeValueToCommandCharacteristic("KU\(path)")
    }
    
    func reboot(){
        writeValueToCommandCharacteristic("B")
    }
    
    func info(){
        writeValueToCommandCharacteristic("I")
    }
    
    func fondeixar(){
        if chain < (depth + marginDepth) {
            operation = .fondeixar
            goto(depth + marginDepth)
        }
    }
    
    func levar(){
        if chain > depth  {
            operation = .levar
            goto(depth - marginDepth)
        }
    }
    
    func pendura(){
        operation = .pendura
        goto(penduraChain)
        
    }
}

// Usage example:

let bleCentralManager = BLECentralManager()

// Assuming you have a Data object to write to the write-only characteristic
//let commandData = "YourCommandData".data(using: .utf8)!
//bleCentralManager.writeValueToCommandCharacteristic(commandData)
