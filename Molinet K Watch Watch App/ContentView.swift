//
//  ContentView.swift
//  Molinet K Watch Watch App
//
//  Created by Francisco Gorina Vanrell on 10/12/23.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) var phase : ScenePhase
    @ObservedObject var server = BLECentralManager.shared
    
    var body: some View {
        VStack {
            HStack{
                Text(server.connectionState == .connected ? "\(server.chain.stringValue)" : "\(server.connectionState.rawValue)").font((Font.system(size: 60)))
                Text(server.connectionState == .connected ? " m" : "").font((Font.system(size: 30)))
            }.onTapGesture {
                server.connect()
            }
            .frame(width: 180, height: 70)
            .background(Color(UIColor.darkGray))
            .cornerRadius(20)
            Spacer()
            HStack {
                Button(action:{
                    print("Up")
                    server.up()
                }) {
                    Image(systemName: "arrowtriangle.up.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    
                }
                .tint(server.state == .Up ? Color(UIColor.red) : Color(UIColor.lightGray))
                
                
                
                Button(action:{
                    print("Down")
                    server.down()
                }) {
                    Image(systemName: "arrowtriangle.down.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    
                }
                .tint(server.state == .Down ? Color(UIColor.red) : Color(UIColor.lightGray))
                
                
            }.frame(width: 180)
            
            
            Button("STOP"){
                print("Stop")
                server.stop()
            }.frame(width: 180)
        }
        .padding()
        .onChange(of: phase) { oldValue, newValue in
            switch newValue {
            case .active:
                server.connect()
                
                break;
            case .inactive:
                server.close()
                break;
            default:
                break
            }
        }
        
    }
}

#Preview {
    ContentView()
}
