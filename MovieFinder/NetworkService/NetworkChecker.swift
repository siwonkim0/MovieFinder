//
//  NetworkChecker.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/21.
//

import Foundation
import Network

class NetworkChecker {
    static let shared = NetworkChecker()
    private let monitor: NWPathMonitor
    var isConnected: Bool = false
    private var connectionType: ConnectionType = .unknown
    
    enum ConnectionType {
        case wifi
        case cellular
        case unknown
    }
    
    private init() {
        monitor = NWPathMonitor()
        self.startMonitoring()
    }
    
    func startMonitoring() {
        monitor.start(queue: DispatchQueue.global())
        monitor.pathUpdateHandler = { [weak self] path in
            switch path.status {
            case .satisfied:
                self?.isConnected = true
            case .unsatisfied:
                self?.isConnected = false
            default:
                break
            }
        }
    }

}
