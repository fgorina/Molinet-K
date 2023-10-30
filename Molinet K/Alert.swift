//
//  Alert.swift
//  ChartCalculator
//
//  Created by Francisco Gorina Vanrell on 18/1/23.
//

import Foundation
import SwiftUI

struct Alert : View {
    
    private enum Field: Int, Hashable {
        case answer
    }
    
    @State var title : String
    @State var prompt : String
    @Binding var isShown : Bool
    var f : (String?) -> Void
    @State var text : String = ""
    @FocusState private var focusedField : Field?
    
    
    
    var body : some View{
     
            VStack{
                Text(title).bold()
                Spacer().frame(height: 30)
                Text(prompt).multilineTextAlignment(.leading)
                TextField(prompt, text: $text)
                    .frame(width:200)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .answer)
                    .onAppear{
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            self.focusedField = .answer
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
                        f(text)
                        isShown = false
                    }.keyboardShortcut(.return, modifiers: [])
                    Spacer()
                }
                
            }.padding().background(.background)
        
            .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(UIColor.opaqueSeparator), lineWidth: 4)
            )
        
    }
    
    
}

struct Alert_Preview: PreviewProvider {
    static var previews: some View {
        Alert(title: "Enter Data", prompt: "Enter your password", isShown: .constant(true)) { str in
            print(str ?? "")
        }.frame(width: 400, height: 200)
        
    }
}
