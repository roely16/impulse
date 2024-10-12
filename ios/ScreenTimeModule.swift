import Foundation
import FamilyControls
import DeviceActivity
import ManagedSettings
import React
import SwiftUI
import SwiftData

extension ManagedSettingsStore.Name {
  static let daily = Self("daily")
}

extension DeviceActivityName {
  static let activiy = Self("activity testing")
}

@objc(ScreenTimeModule)
class ScreenTimeModule: NSObject {
    
  var appsSelected: Set<ApplicationToken> = []
  let store = ManagedSettingsStore(named: .daily)
  
  func handleAuthorizationError(_ error: Error, reject: @escaping RCTPromiseRejectBlock) {
      let errorCode = "E_AUTHORIZATION_FAILED"
      let errorMessage = "Failed to request authorization: \(error.localizedDescription)"
      reject(errorCode, errorMessage, error)
  }

  @objc
  func requestAuthorization(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
      if #available(iOS 16.0, *) {
          Task {
              do {
                  try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                  resolve(["status": "success", "message": "Authorization requested successfully."])
              } catch {
                  handleAuthorizationError(error, reject: reject)
              }
          }
      } else {
          reject("E_UNSUPPORTED_VERSION", "This functionality requires iOS 16.0 or higher.", nil)
      }
  }

  @objc(showAppPicker:rejecter:)
  func showAppPicker(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    DispatchQueue.main.async {
      if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let window = scene.windows.first {
        
        let pickerView = ActivityPickerView { updatedSelection in
          let applications = updatedSelection.applications
          self.appsSelected = updatedSelection.applicationTokens
          print("Aplicaciones seleccionadas: \(updatedSelection.applications.count)")
          resolve(["status": "success", "totalSelected" : updatedSelection.applications.count])
        }
        
        let controller = UIHostingController(rootView: pickerView)
        controller.modalPresentationStyle = .fullScreen
        window.rootViewController?.present(controller, animated: true, completion: nil)
      } else {
          reject("Error", "Could not find the root window", nil)
      }
    }
  }

  @MainActor @objc
  func createBlock(_ name: String, startTime: String, endTime: String, resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    let deviceActivityCenter = DeviceActivityCenter();
    
    do {
      let configuration = ModelConfiguration(isStoredInMemoryOnly: false, allowsSave: true, groupContainer: ( .identifier("group.com.impulsecontrolapp.impulse.share") ))
      let container = try ModelContainer(
        for: Block.self,
        configurations: configuration
      )
      
      let context = container.mainContext
      
      let block = Block(
        name: name,
        appsTokens: self.appsSelected,
        startTime: startTime,
        endTime: endTime
      )
      context.insert(block)
      try context.save()
      
      let startTimeComponents = startTime.split(separator: ":")
      let endTimeComponents = endTime.split(separator: ":")

      try deviceActivityCenter.startMonitoring(DeviceActivityName(rawValue: block.id.uuidString) , during: DeviceActivitySchedule(
        intervalStart: DateComponents(hour: Int(startTimeComponents[0]), minute: Int(startTimeComponents[1])),
        intervalEnd: DateComponents(hour: Int(endTimeComponents[0]), minute: Int(endTimeComponents[1])),
        repeats: false
      ))
      
      resolve(["status": "success", "appsBlocked": self.appsSelected.count])

    } catch {
      print("Error saving")
    }
    
//    do {
//
//      print("Monitoring started")
//    } catch {
//      print("Failed to start monitoring: \(error.localizedDescription)")
//    }
  }
  
  @objc
  func readLastLog(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    let sharedDefaults = UserDefaults(suiteName: "group.com.impulsecontrolapp.impulse.share")

    if let lastActivityLog = sharedDefaults?.string(forKey: "lastActivityLog") {
        print("Última actividad registrada: \(lastActivityLog)")
    } else {
        print("No se encontró ningún valor para 'lastActivityLog'")
    }
  }
  
  @MainActor @objc
  func getBlocks(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    do {
      let configuration = ModelConfiguration(groupContainer: ( .identifier("group.com.impulsecontrolapp.impulse.share") ))
      let container = try ModelContainer(
        for: Block.self,
        configurations: configuration
      )
      
      let context = container.mainContext
      
      let fetchDescriptor = FetchDescriptor<Block>()
      let blocks = try context.fetch(fetchDescriptor)
      
      let blocksArray = blocks.map { block -> [String: Any] in
        return [
            "id": block.id.uuidString, // Asegúrate de que 'id' sea un UUID
            "title": block.name, // Reemplaza con los campos de tu modelo
            "subtitle": "\(block.startTime) • \(block.endTime)",
            "apps": block.appsTokens.count
        ]
      }
      resolve(["status": "success", "blocks" : blocksArray])
    } catch {
      print("Error getting blocks")
    }
  }
  
  @MainActor @objc
  func deleteBlock(_ blockId: String, resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    do {
      guard let uuid = UUID(uuidString: blockId) else {
        reject("invalid_uuid", "El blockId proporcionado no es un UUID válido.", nil)
        return
      }
      let configuration = ModelConfiguration(groupContainer: ( .identifier("group.com.impulsecontrolapp.impulse.share") ))
      let container = try ModelContainer(
        for: Block.self,
        configurations: configuration
      )
      let context = container.mainContext
      
      // Remove restriction
      let store = ManagedSettingsStore(named: ManagedSettingsStore.Name(rawValue: blockId))
      store.shield.applications = nil
      
      // Delete from store
      try context.delete(model: Block.self, where: #Predicate { $0.id == uuid })
      resolve("Block deleted")
    } catch {
      reject("Error", "Could not delete block", nil)
    }
  }
  
  @objc static func requiresMainQueueSetup() -> Bool {
      return true
  }
}

