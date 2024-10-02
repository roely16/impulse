import Foundation
import ScreenTime
import React

@objc(ScreenTimeModule)
class ScreenTimeModule: NSObject {

    @objc
    func getScreenTimeUsage(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        // Implementar aquí el acceso a la API de Screen Time
        // Por ejemplo, obtener el tiempo de pantalla usado por aplicaciones
        let screenTimeData = // lógica para obtener datos de Screen Time

        reject("no_data", "No Screen Time data available", nil)
    }

    @objc static func requiresMainQueueSetup() -> Bool {
        return true
    }
}

