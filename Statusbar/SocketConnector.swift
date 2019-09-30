//
//  SocketManager.swift
//  Statusbar
//
//  Created by Erik de Groot on 25/09/2019.
//  Copyright © 2019 Tjuna. All rights reserved.
//

import Foundation
import SocketIO

class SocketConnector {
    let apiURL: String
    let manager = SocketManager(
        socketURL: URL(string: Config.API_URL)!,
        config: [.log(Config.SOCKET_LOGGING), .compress]
    )
    var socket: SocketIOClient
    let model: LocationModel

    init(model: LocationModel) {

        self.apiURL = model.apiURL
        self.model = model
        self.socket = self.manager.defaultSocket

        self.socketConnect()
    }

    func listen(event: String) {
        socket.on(event) {response, _ in
            let rawJson = response[0] as! String

            self.model.handleSocketResponse(rawJson)
        }
    }

    func socketConnect() {
        socket.on("connect") {_, _ in
            print("socket connected")
        }

        socket.connect()
    }

    deinit {
        self.closeConnection()
    }

    func closeConnection() {
        socket.disconnect()
    }

}
