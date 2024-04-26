//
//  NetworkMonitor.swift
//  pruebaApp
//
//  Created by Juan Sebastian Ibañez Capacho on 18/04/24.
//

import Foundation
import Network

class NetworkMonitor:ObservableObject{
    let queue = DispatchQueue( label: "Network monitor queue")
    let monitor = NWPathMonitor()
    
    @Published var isConnected = true
    
    init(){
        monitor.pathUpdateHandler = {path in
            DispatchQueue.global(qos: .background).async{
                self.isConnected = path.status == .satisfied ?true:false
            }
        }
        monitor.start(queue:queue)
    }
}

