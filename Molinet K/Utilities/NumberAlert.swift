//
//  Alert.swift
//  ChartCalculator
//
//  Created by Francisco Gorina Vanrell on 18/1/23.
//

import Foundation
import SwiftUI

struct NumberAlert : View {
    
    private enum Field: Int, Hashable {
        case answer
    }
    
    @State var title : String
    @State var prompt : String
    @Binding var isShown : Bool
    var f : (Double?) -> Void
    @State var value : Double = 0.0
    
    @FocusState private var focusedField : Field?

    let formatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return formatter
        }()

    
    var body : some View{
     
            VStack{
                Text(title).bold()
                Spacer().frame(height: 30)
                Text(prompt).multilineTextAlignment(.leading)
                TextField(prompt, value: $value, formatter: formatter)
                    .keyboardType(.decimalPad)
                    .frame(width: 200)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .answer)
                    .onAppear{
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            self.focusedField = .answer
                        }
                    }.onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                        // Click to select all the text.
                        if let textField = obj.object as? UITextField {
                            textField.selectAll(nil)
                        }
                    }
            
                Spacer().frame(height: 30)
                HStack{
                    Spacer()
                    Button("Cancel"){
                        f(nil)
                        isShown = false
                    }.keyboardShortcut(.escape, modifiers: [])
                    Spacer()
                    Button("OK"){
                        f(value)
                        isShown = false
                    }.keyboardShortcut(.return, modifiers: [])
                    Spacer()
                }
                
            }.padding().background(.background)
        
            .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(UIColor.opaqueSeparator), lineWidth: 4)
            ).shadow(radius: 5)
        
    }
}

struct NumberAlert_Preview: PreviewProvider {
    static var previews: some View {
        Alert(title: "Enter Data", prompt: "Enter your password", isShown: .constant(true)) { v in
            print(v ?? 0.0)
        }.frame(width: 400, height: 200)
        
    }
}
