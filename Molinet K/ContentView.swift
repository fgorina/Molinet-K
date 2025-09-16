//
//  ContentView.swift
//  Molinet K
//
//  Created by Francisco Gorina Vanrell on 24/10/23.
//

import SwiftUI
import OSLog

struct ContentView: View {
    
    @Environment(\.scenePhase) var phase : ScenePhase
    
   // @ObservedObject var server = SignalKServer.shared
    
    @State var showConfig = false
    @State var askDepth = false
    @State var askTarget = false
    @State var askQuantityUp = false
    @State var askQuantityDown = false
    @State var depth = 0.0
    
    @ObservedObject var server = BLECentralManager.shared
    
    var body: some View {
        ZStack{
            VStack(alignment: .center) {
                HStack{
                    Spacer()
                    Text("Yamato")
                        .font(.largeTitle)
                    Spacer()
                    Button{
                        showConfig = true
                    }
                label:{
                    Image(systemName: "gearshape")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                }
                
                Text("Molinet Àncora")
                    .font(.largeTitle)
                Spacer()
                VStack(){
                    HStack(alignment: .top){
                        Text("Cadena")
                        Spacer()
                        Text(server.state.description)
                    }.padding(EdgeInsets(top: 5.0, leading: 10.0, bottom: 0.0, trailing: 10.0))
                    HStack{
                        Text(server.chain.stringValue)
                            .font(Font.system(size: 120)).bold()
                        Text("m")
                            .font(Font.system(size: 30)).bold()
                    }
                    Spacer()
                    
                }
                .frame(width: 330, height: 180.0)
                .background(server.connectionState == .connected ? Color(UIColor.secondarySystemBackground) : Color.pink)
                .cornerRadius(20)
                .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                .onTapGesture {
                    askTarget = true
                }
                
                VStack(){
                    HStack(alignment: .center){
                        Text("Profunditat").font(Font.system(size: 30))
                        Spacer()
                        Text(server.depth.rounded().formatted(decimals: 0))
                            .font(Font.system(size: 30)).bold()
                        Text("m")
                    }.padding(EdgeInsets(top: 5.0, leading: 10.0, bottom: 10.0, trailing: 10.0))
                }.frame(width: 330, height: 60.0)
                    .background(server.connectionState == .connected ? Color(UIColor.secondarySystemBackground) : Color.pink)
                    .cornerRadius(20)
                    .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                    .onTapGesture {
                        askDepth = true
                    }
                
                Spacer()
                
                HStack{
                    Button(action:{
                        
                    }) {
                        Image(systemName: "arrowtriangle.up.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
                    }
                    .buttonStyle(PrimaryButtonStyle(backgroundColor: server.state == .Up ? .pink : Color(UIColor.secondarySystemFill)))
                    .frame(width: 150)
                    .simultaneousGesture(TapGesture().onEnded { _ in
                        server.up()
                    })
                    .simultaneousGesture(LongPressGesture().onEnded { _ in
                        askQuantityUp = true
                    })
                    
                    Spacer()
                    
                    
                    Button(action: {
                        
                    }){
                        Image(systemName: "arrowtriangle.down.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
                    }
                    .buttonStyle(PrimaryButtonStyle(backgroundColor: server.state == .Down ? .pink : Color(UIColor.secondarySystemFill)))
                    .frame(width: 150)
                    .simultaneousGesture(TapGesture().onEnded { _ in
                        server.down()
                    })
                    .simultaneousGesture(LongPressGesture().onEnded { _ in
                        askQuantityDown = true
                    })
                    
                }
                Spacer()
                HStack{
                    Button(action:{
                        server.levar()
                    }) {
                        Image(systemName: "arrow.up.to.line")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
                    }
                    .buttonStyle(PrimaryButtonStyle(backgroundColor: server.operation == .levar ? .pink : Color(UIColor.secondarySystemFill)))
                    .frame(width: 80, height: 80)
                    
                    Spacer()
                    Button(action:{
                        server.pendura()
                    }) {
                        Image(systemName: "record.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
                    }.buttonStyle(PrimaryButtonStyle(backgroundColor: server.operation == .pendura ? .pink : Color(UIColor.secondarySystemFill)))
                        .frame(width: 80, height: 80)
                    
                    Spacer()
                    Button(action: {
                        server.fondeixar()
                    }){
                        Image(systemName: "arrow.down.to.line")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
                    }
                    
                    
                    .buttonStyle(PrimaryButtonStyle(backgroundColor: server.operation == .fondeixar ? .pink : Color(UIColor.secondarySystemFill)))
                    .frame(width: 80, height: 80)
                    
                }
                Spacer()
                Button("STOP"){
                    server.stop()
                }
                
                .buttonStyle(PrimaryButtonStyle(backgroundColor: .red,
                                                textColor: .white))
                
                
                Spacer()
            }
            .padding()
            
            if showConfig {
                ConfigView(isShown: $showConfig)
                    .frame(width: 300, height: 300)
            }
            if askDepth {
                NumberAlert(title: "Profunditat", prompt: "Entreu la profunditat en m", isShown: $askDepth) { v in
                    server.depth = v ?? server.depth
                }.frame(width: 300, height: 300)
            }
            if askQuantityUp {
                NumberAlert(title: "Cadena", prompt: "Quants m voleu pujar?", isShown: $askQuantityUp) { v in
                    if let v = v {
                        server.move(-abs(v))
                    }
                }.frame(width: 300, height: 300)
            }
            if askQuantityDown {
                NumberAlert(title: "Cadena", prompt: "Quants m voleu deixar anar?", isShown: $askQuantityDown) { v in
                    if let v = v {
                        server.move(abs(v))
                    }
                }.frame(width: 300, height: 300)
            }
            
            if askTarget {
                NumberAlert(title: "Cadena", prompt: "Entreu la longitut de cadena desitjada en m", isShown: $askTarget) { v in
                    
                    if let v = v {
                        server.goto(v)
                    }
                    
                }.frame(width: 300, height: 300)
            }
            
            
        }.onAppear(){
            UIApplication.shared.isIdleTimerDisabled = true
        }.onDisappear(){
            UIApplication.shared.isIdleTimerDisabled = false
        }.onChange(of: phase, initial: true){ oldPhase, newPhase  in
            switch newPhase {
                
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

struct PrimaryButtonStyle: ButtonStyle {
    
    var backgroundColor: Color = Color(UIColor.secondarySystemFill)
    var textColor: Color = Color.accentColor
    var height: CGFloat = 100
    var cornerRadius: CGFloat = 15
    var fontSize: CGFloat = 80
    var disabled: Bool = false
    var textSidePadding: CGFloat = 30
    var weight: Font.Weight = .semibold
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding([.leading, .trailing], textSidePadding)
            .frame(maxWidth: .infinity, maxHeight: height)
            .background(disabled ? .gray : backgroundColor)
            .foregroundColor(textColor)
            .cornerRadius(cornerRadius)
            .font(.system(size: fontSize, weight: weight, design: .default))
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
