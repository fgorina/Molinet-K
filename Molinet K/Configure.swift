//
//  Alert.swift
//  ChartCalculator
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
    @State var lChain : Double = 0.0
    @State var mmPulse : Double = 0.0
    
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
                    Text("Configuració").bold()
                    Spacer()
                    Button{
                        isShown = false
                    }
                label:{
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
                        }.onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                            // Click to select all the text.
                            if let textField = obj.object as? UITextField {
                                textField.selectAll(nil)
                            }
                        }
                        
                    Button{
                        
                        SignalKServer.shared.setMaxChain(lChain)
                        
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
                        .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                            // Click to select all the text.
                            if let textField = obj.object as? UITextField {
                                textField.selectAll(nil)
                            }
                        }
                    
                    Button{
                        SignalKServer.shared.calibrate(mmPulse)
                    }label:{
                        Image(systemName: "link.circle")
                           
                    }
                }

            
                
                Spacer()
                Button("Ajustar Cero"){
                    SignalKServer.shared.resetChain()
                }.buttonStyle(.bordered)
 
                Spacer()
            
                Button("Reconnect"){
                    if !SignalKServer.shared.isReceiving {
                        Task{
                            do{
                                try SignalKServer.shared.connect()
                            }catch{
                                Logger.signalk.error("Error al connectar al servidor \(error.localizedDescription)")
                            }
                        }
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
