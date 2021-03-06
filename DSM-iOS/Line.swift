//
//  API.swift
//  DSM-iOS
//
//  Created by Jannik Lorenz on 01.11.15.
//  Copyright © 2015 Jannik Lorenz. All rights reserved.
//

import Foundation
import Socket_IO_Client_Swift
import SwiftyJSON


var DSCLineKey = "123"
var lines = [
    Line(url: "192.168.101.101:3000", title: "Test Linie 1", id: "lineTest1"),
    
//    Line(url: "192.168.101.101:3000", title: "Linie 1", id: "line1"),
//    Line(url: "192.168.101.101:3000", title: "Linie 2", id: "line2"),
//    Line(url: "192.168.101.101:3000", title: "Linie 3", id: "line3"),
//    Line(url: "192.168.101.101:3000", title: "Linie 4", id: "line4"),
//    Line(url: "192.168.101.101:3000", title: "Linie 5", id: "line5"),
//    Line(url: "192.168.101.101:3000", title: "Linie 6", id: "line6"),
//    Line(url: "192.168.101.101:3000", title: "Linie 7", id: "line7"),
//    Line(url: "192.168.101.101:3000", title: "Linie 8", id: "line8"),
//    Line(url: "192.168.101.101:3000", title: "Linie 9", id: "line9"),
//    Line(url: "192.168.101.101:3000", title: "Linie 10", id: "line10"),
//    Line(url: "192.168.101.101:3000", title: "Linie 11", id: "line11"),
//    Line(url: "192.168.101.101:3000", title: "Linie 12", id: "line12"),
]


class Line {
    var socket: SocketIOClient?
    let events = EventManager()
    
    var title = ""
    var id = ""
    
    var session: JSON?
    var config: JSON?
    
    init(url: String, title: String = "", id: String = ""){
        self.title = title
        self.id = id
        
        socket = SocketIOClient(socketURL: url, options: [.Log(false), .ForcePolling(true)])
        
        socket?.on("connect") {data, ack in
            self.events.trigger("connect", information: self.id)
        }
        socket?.on("disconnect") {data, ack in
            self.events.trigger("disconnect", information: self.id)
        }
        socket?.on("error") {data, ack in
            self.events.trigger("error", information: self.id)
        }
        
        socket?.on("setSession") { (data, ack) -> Void in
            self.session = JSON(data)[0]
            self.events.trigger("setSession", information: self.id)
        }
        socket?.on("setConfig") { (data, ack) -> Void in
            self.config = JSON(data)[0]
            self.events.trigger("setConfig", information: self.id)
        }
        
        
        // TODO... all methods
        
        socket?.connect()
    }
    
    
    
    
    
    
    // MARK: API
    
    enum DSCAPIMethod: String {
        case setPart = "setPart"
        case setDisziplin = "setDisziplin"
        case showMessage = "showMessage"
        case hideMessage = "hideMessage"
        case getConfig = "getConfig"
        case getSession = "getSession"
    }
    enum DSCAPIMethodMessage: String {
        case danger = "danger"
        case black = "default"
    }
    
    
    
    
    func getConfig() {
        triggerSocket(.setPart)
    }
    func getSession() {
        triggerSocket(.setPart)
    }
    
    
    
    func setPart(part: String) {
        var data = [String: AnyObject]()
        data["partId"] = part
        
        triggerSocket(.setPart, data: data)
    }
    
    func setDisziplin(disziplin: String) {
        var data = [String: AnyObject]()
        data["disziplin"] = disziplin
        
        triggerSocket(.setDisziplin, data: data)
    }
    
    
    
    func showMessage(message: String, type: DSCAPIMethodMessage) {
        var data = [String: AnyObject]()
        data["title"] = message
        data["type"] = type.rawValue
        
        triggerSocket(.showMessage, data: data)
    }
    func hideMessage() {
        triggerSocket(.hideMessage)
    }
    
    
    
    
    
    // Trigger Socket with given data and method
    private func triggerSocket(method: DSCAPIMethod, var data: [String: AnyObject] = [String: AnyObject]()) {
        switch (method) {
        case .setPart, .setDisziplin, .showMessage, .hideMessage:
            data["auth"] = ["key": DSCLineKey]
        default:
            break
        }
        socket?.emit(method.rawValue, data)
    }
}