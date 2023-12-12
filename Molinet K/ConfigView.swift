//
//  ConfigView.swift
//
//  Configuració de paràmetres del molinet
//
//  Created by Francisco Gorina Vanrell on 18/1/23.
//

import Foundation
import SwiftUI
import OSLog

struct ConfigView : View {
    
    private enum Field: Int, Hashable {
        case longCadena
        case mmPulse
    }
    
    
    @Binding var isShown : Bool
    @State var lChain : Double = BLECentralManager.shared.deviceState.lChain
    @State var mmPulse : Double = BLECentralManager.shared.deviceState.mmPulse
    @State var deviceName : String = BLECentralManager.shared.deviceState.deviceName
    @State var ssid : String = BLECentralManager.shared.deviceState.ssid
    @State var password : String = BLECentralManager.shared.deviceState.password
    @State var host : String = BLECentralManager.shared.deviceState.host
    @State var port : Int = (BLECentralManager.shared.deviceState.port)
    @State var path : String = BLECentralManager.shared.deviceState.path

    
    
    
    @FocusState private var focusedField : Field?
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var body : some View{
        
        VStack{
            HStack{
                Spacer()
                Text("Configuració \(BLECentralManager.shared.deviceState.wsState.stringValue)").bold()
                Spacer()
                Button{
                    isShown = false
                }label:{
                    Image(systemName: "xmark.circle")
                    
                }
            }
            Spacer()
            HStack{
                Text("Long. Cadena").frame(width: 120, alignment: Alignment.trailing)
                Spacer()
                TextField("en m", value: $lChain, formatter: formatter)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.trailing)
                    .focused($focusedField, equals: .longCadena)
                    .frame(width:80)
                    .onAppear{
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            self.focusedField = .longCadena
                        }
                    }
                    /*.onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                        // Click to select all the text.
                        if let textField = obj.object as? UITextField {
                            textField.selectAll(nil)
                        }
                    }*/
                
                Button{
                    
                    BLECentralManager.shared.setMaxChain(lChain)
                    
                }label:{
                    Image(systemName: "link.circle")
                    
                }
            }
            Spacer()
            HStack{
                Text("Calibració").frame(width: 120, alignment: Alignment.trailing)
                Spacer()
                TextField("mm / volta", value: $mmPulse, formatter: formatter)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.trailing)
                    .frame(width:80)
                    /*.onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                        // Click to select all the text.
                        if let textField = obj.object as? UITextField {
                            textField.selectAll(nil)
                        }
                    }*/
                
                Button{
                    //SignalKServer.shared.calibrate(mmPulse)
                    BLECentralManager.shared.calibrate(mmPulse)                    
                }label:{
                    Image(systemName: "link.circle")
                    
                }
            }
            Spacer()
            Text("Device Name").frame(width: 120, alignment: Alignment.trailing)
            HStack{

                TextField("Device Name", text: $deviceName)
                    .textFieldStyle(.roundedBorder)
                
                Button{
                    //SignalKServer.shared.calibrate(mmPulse)
                    BLECentralManager.shared.setDeviceName(deviceName)
                    BLECentralManager.shared.deviceState.deviceName = deviceName
                }label:{
                    Image(systemName: "link.circle")
                    
                }
            }
            Spacer()
            Text("SSID Network").frame(width: 120, alignment: Alignment.trailing)
            HStack{

                TextField("SSID", text: $ssid)
                    .textFieldStyle(.roundedBorder)
                
                Button{
                    //SignalKServer.shared.calibrate(mmPulse)
                    BLECentralManager.shared.setSSID(ssid)
                    BLECentralManager.shared.deviceState.ssid = ssid
                }label:{
                    Image(systemName: "link.circle")
                    
                }
            }
            
            Spacer()
            Text("Password").frame(width: 120, alignment: Alignment.trailing)
            HStack{

                TextField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                
                Button{
                    //SignalKServer.shared.calibrate(mmPulse)
                    BLECentralManager.shared.setPassword(password)
                    BLECentralManager.shared.deviceState.password = password
                }label:{
                    Image(systemName: "link.circle")
                    
                }
            }
            Spacer()
            Text("SignalK Server").frame(width: 120, alignment: Alignment.trailing)
            HStack{

                VStack{
                    HStack{
                        TextField("Host", text: $host)
                            .textFieldStyle(.roundedBorder)
                        
                        TextField("Port", value: $port, formatter: formatter)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    
                    TextField("path", text: $path)
                        .textFieldStyle(.roundedBorder)
                }
                
                Button{
                    //SignalKServer.shared.calibrate(mmPulse)
                    BLECentralManager.shared.setSignalKServer(ip: host, port: port, path: path)
                    BLECentralManager.shared.deviceState.host = host
                    BLECentralManager.shared.deviceState.port = port
                    BLECentralManager.shared.deviceState.path = path
                }label:{
                    Image(systemName: "link.circle")
                    
                }
            }


            Spacer()
            Button("Ajustar Cero"){
                BLECentralManager.shared.resetChain()
            }.buttonStyle(.bordered)
            
            Spacer()
            Button("Reconnect"){
                if BLECentralManager.shared.connectionState != .connected {
                    BLECentralManager.shared.connect()
                    
                }
            }.buttonStyle(.bordered)
        }.padding().background(.background)
            .shadow(radius: 5)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(UIColor.opaqueSeparator), lineWidth: 4)

            )
        
    }
}

struct ConfigView_Preview: PreviewProvider {
    static var previews: some View {
        ConfigView( isShown: .constant(true)).frame(width: 300, height: 300)
        
    }
}
