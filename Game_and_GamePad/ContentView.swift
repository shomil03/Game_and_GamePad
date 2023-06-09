//
//  ContentView.swift
//  Game_and_Gamepad
//
//  Created by Shomil Singh on 30/05/23.
//

//[
//    "direction" : true, // true means upward, false means down
//    "pressed" : true // true means pressed, false means released
//]

import SwiftUI

struct ContentView: View {
    @State private var ispressed:Bool=false
    @State private var direction:Bool=false
    
 
    let json = "[\n\"direction\" : \"true\",\n\"pressed\" : \"true\"\n]"
    @FocusState private var pressed:Bool
    
    

    let session: URLSession
    private var websocket: URLSessionWebSocketTask?
    private var delegate: WebSocketDelegate?
    
    init() {
        let configuration = URLSessionConfiguration.default
        session = URLSession(configuration: configuration)
        let url = URL(string: "ws://192.168.135.220:3000/player")!
        websocket = session.webSocketTask(with: url)
        delegate = WebSocketDelegate(websocket: websocket)
        websocket?.delegate = delegate
        websocket?.resume()
    }
   
    @State var button:String="No button"
    
    @State var status:Bool=false
    var body: some View {
       
        ZStack{

            let color1 = Color(red: 255/255, green: 216/255, blue: 155/255)
            let color2 = Color(red: 25/255, green: 84/255, blue: 123/255)
            LinearGradient(gradient: Gradient(colors: [color1, color2]), startPoint: .topLeading, endPoint: .bottomLeading)
                .ignoresSafeArea()
            
            

            VStack {
                
                
                Text("GameAndGamepad")
                    .foregroundColor(Color.black)
                    .bold()
                    .font(.largeTitle)
                    .padding(25)
                    Spacer()
//                Text("\(button) was \(status)")
               
      
                VStack{
                   

                    Button()
                    {
                        pressed.toggle()
                        printf()

                    }label:{
                        Label("UP",systemImage: "arrowtriangle.up.fill")
                            .font(.custom("Arial", size: 70))
                            .foregroundColor(Color(red: 20/255, green: 33/255, blue: 61/255))
                            .simultaneousGesture(DragGesture(minimumDistance: 0).onChanged(
                                {_ in
                                    button="UP"
                                    status=true
//                                    print("Up button was pressed")
                                    direction=true
                                    send()
                                    
                                })
                                .onEnded({_ in
                                    button="UP"
                                    status=false
                                    direction=true
                                    send()
//                                    print("Up button was released")
                                }))
                            
                            
                            
                    }.focused($pressed)

                    .padding(20)
                    
                   
                    Spacer()
                  
                    Button()
                    {
                       printf()
                        
                    }label:{
                        Label("Down",systemImage: "arrowtriangle.down.fill")
                            .foregroundColor(Color(red: 20/255, green: 33/255, blue: 61/255))
                    }
                    .padding(35)
                    .font(.custom("Arial", size: 70))
                    .simultaneousGesture(DragGesture(minimumDistance: 0).onChanged(
                        {_ in
                            button="Down"
                            status=true
                            direction=false
//                            print("Down button was pressed")
                            send()
                        })
                        .onEnded({_ in
                            button="Down"
                            status=false
                            direction=false
                            send()
//                            print("Down button was released")
                        }))
              
                }
                .frame(minWidth: 100, maxWidth: .infinity, minHeight: 300,maxHeight:300)
                

                .padding(20)
                    Spacer()
                }
            
           
              
//
//=
//
//                Button("Send data")
//                {
//                    send()
//                }
//                .fontWeight(.bold)
//                .font(.title)
//                .foregroundColor(Color.indigo)
//                .buttonStyle(.bordered)
//                .padding()
//
//                Button("Receive data")
//                {
//                    receive()
//                }
//                .font(.title)
//                .buttonStyle(.bordered)
//
//                .foregroundColor(Color.orange)
//
//                .padding()
//                Spacer()
//                Spacer()
                
                
                
            
        }
            
    }
    func printstatus(){
        
    }
   
    
    func printf(){
//        print("pressed:- \(pressed)")
    }
    
    func ping() {
        delegate?.ping()
    }
    func close(){
        delegate?.close()
    }
    func send(){
        delegate?.send(direction: direction, status: status)
    }
    func receive() {
        delegate?.receive()
    }
}

class WebSocketDelegate: NSObject, URLSessionWebSocketDelegate {
    private var websocket: URLSessionWebSocketTask?
    
    init(websocket: URLSessionWebSocketTask?) {
        self.websocket = websocket
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Did connect to socket")
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Out of connection")
    }
    
    func ping() {
        websocket?.sendPing { error in
            if let error = error {
                print("Ping error: \(error)")
            }
        }
    }
    func close(){
        websocket?.cancel(with: .goingAway, reason: "Demo ended".data(using: .utf8))
    }
//    direction: true
//    pressed: true
    func send(direction:Bool , status:Bool){
        let json="{\"direction\": \(direction),\"pressed\":\(status)}"
        print(json)
        websocket?.send(.string(json), completionHandler: {error in
            if let error=error{
                print("Send error \(error)")
            }
        })
    }

    func receive(){
        websocket?.receive(completionHandler: {result in
            switch result{
            case .success(let message):
                switch message{
                case .data(let data):
                    print("Got data: \(data)")
                case .string(let message):
                    print("Got message: \(message)")
                @unknown default:
                    break
                }
            case .failure(let error):
                print("Receive error: \(error)")
            }
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
