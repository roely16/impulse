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
//  var sitesSelected: Set<WebDomainToken> = []
//  var familySelection: FamilyActivitySelection = FamilyActivitySelection()
  let store = ManagedSettingsStore(named: .daily)
  
  func handleAuthorizationError(_ errorCode: String? = nil, error: Error, reject: @escaping RCTPromiseRejectBlock) {
      let finalErrorCode = errorCode ?? "FAILED"
      let errorMessage = "Failed to request authorization: \(error.localizedDescription)"
      reject(finalErrorCode, errorMessage, error)
  }


  @objc
  func requestAuthorization(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
      if #available(iOS 16.0, *) {
          Task {
              do {
                  try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                  resolve(["status": "success", "message": "Authorization requested successfully."])
              } catch {
                handleAuthorizationError(error: error, reject: reject)
              }
          }
      } else {
          reject("E_UNSUPPORTED_VERSION", "This functionality requires iOS 16.0 or higher.", nil)
      }
  }

  @MainActor @objc
  func showAppPicker(_ isFirstSelection: Bool, resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    DispatchQueue.main.async {
      if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let window = scene.windows.first {
        
        let pickerView = ActivityPickerView(isFirstSelection: isFirstSelection) { updatedSelection in
          let applications = updatedSelection.applications
          self.appsSelected = updatedSelection.applicationTokens
          print("Apps selected: \(updatedSelection.applications.count)")
          print("Categories selected: \(updatedSelection.categories.count)")
          print("Sites selected: \(updatedSelection.webDomains.count)")
          resolve([
            "status": "success",
            "appsSelected" : updatedSelection.applications.count,
            "categoriesSelected" : updatedSelection.categories.count,
            "sitesSelected" : updatedSelection.webDomains.count
          ])
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
  func createBlock(_ name: String, startTime: String, endTime: String, weekdays: [Int], resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
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
        endTime: endTime,
        enable: true
      )
      context.insert(block)
      try context.save()
      
      let startTimeComponents = startTime.split(separator: ":")
      let endTimeComponents = endTime.split(separator: ":")
      
      if weekdays.count == 0 {
        try deviceActivityCenter.startMonitoring(
          DeviceActivityName(rawValue: block.id.uuidString),
          during: DeviceActivitySchedule(
            intervalStart: DateComponents(hour: Int(startTimeComponents[0]), minute: Int(startTimeComponents[1])),
            intervalEnd: DateComponents(hour: Int(endTimeComponents[0]), minute: Int(endTimeComponents[1])),
            repeats: false
          )
        )
        print("Only one time \(block.id.uuidString)")
      } else {
        for weekday in weekdays {
          try deviceActivityCenter.startMonitoring(
            DeviceActivityName(rawValue: "\(block.id.uuidString)-day-\(weekday)"),
            during: DeviceActivitySchedule(
              intervalStart: DateComponents(hour: Int(startTimeComponents[0]), minute: Int(startTimeComponents[1]), weekday: weekday),
              intervalEnd: DateComponents(hour: Int(endTimeComponents[0]), minute: Int(endTimeComponents[1]), weekday: weekday),
              repeats: true
            )
          )
          print("Repeat on \(weekday) \(block.id.uuidString)")
        }
      }
      
      resolve(["status": "success", "appsBlocked": self.appsSelected.count])

    } catch {
      reject("Error", "Error trying to create block: \(error.localizedDescription)", error)
    }
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
            "subtitle": "\(block.startTime)-\(block.endTime)",
            "apps": block.appsTokens.count,
            "enable": block.enable
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
  
  @MainActor @objc
  func updateBlockStatus(_ blockId: String, isEnable: Bool, resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
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
      
      let fetchDescriptor = FetchDescriptor<Block>(
        predicate: #Predicate { $0.id == uuid }
      )
      let result = try context.fetch(fetchDescriptor)
      let block = result.first

      block?.enable = isEnable
      
      if !isEnable {
        let store = ManagedSettingsStore(named: ManagedSettingsStore.Name(rawValue: blockId))
        store.shield.applications = nil
      }
      
      try context.save()

      resolve(["status": "success", "blockId" : blockId, "isEnable": isEnable, "blockName": block?.name])
    } catch {
      print("Error updating block status")
    }
  }
  
  @objc static func requiresMainQueueSetup() -> Bool {
      return true
  }
}

