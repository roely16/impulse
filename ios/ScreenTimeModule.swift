import Foundation
import FamilyControls
import DeviceActivity
import ManagedSettings
import React
import SwiftUI
import SwiftData

@objc(ScreenTimeModule)
class ScreenTimeModule: NSObject {
    
  var appsSelected: Set<ApplicationToken> = []
  var familySelection: FamilyActivitySelection = FamilyActivitySelection()
  
  private var container: ModelContainer?
  
  override init() {
    super.init()
    do {
      // Inicializamos el contenedor una vez en el constructor
      let configuration = ModelConfiguration(isStoredInMemoryOnly: false, allowsSave: true, groupContainer: .identifier("group.com.impulsecontrolapp.impulse.share"))
      container = try ModelContainer(for: Event.self, Block.self, Limit.self, configurations: configuration)
    } catch {
      print("Error initializing ModelContainer: \(error)")
    }
  }
  
  @MainActor
  private func getContext() throws -> ModelContext {
    guard let container = container else {
      throw NSError(domain: "container_uninitialized", code: 500, userInfo: [NSLocalizedDescriptionKey: "ModelContainer is not initialized"])
    }
    return container.mainContext
  }
  
  func handleAuthorizationError(_ errorCode: String? = nil, error: Error, reject: @escaping RCTPromiseRejectBlock) {
      let finalErrorCode = errorCode ?? "FAILED"
      let errorMessage = "Failed to request authorization: \(error.localizedDescription)"
      reject(finalErrorCode, errorMessage, error)
  }

  @MainActor @objc
  func requestAuthorization(_ testBlockName: String = "", resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    if #available(iOS 16.0, *) {
      Task {
        do {
          try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
          let context = try getContext()
          let block = Block(
            name: "Bloqueo de prueba",
            appsTokens: [],
            familySelection: self.familySelection,
            startTime: "09:00",
            endTime: "16:00",
            enable: true,
            weekdays: [2,3,4,5,6]
          )
          context.insert(block)
          try context.save()
          
          // Create default block
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
  func showAppPicker(_ isFirstSelection: Bool, blockId: String = "", resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    DispatchQueue.main.async {
      
      if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let window = scene.windows.first {
        
        let pickerView = ActivityPickerView(isFirstSelection: isFirstSelection, blockId: blockId) { updatedSelection in
          let applications = updatedSelection.applications
          applications.forEach{app in
            print("app \(app.token)")
          }
          self.appsSelected = updatedSelection.applicationTokens
          self.appsSelected.forEach{appSelected in
            print("app selected \(appSelected.hashValue)")
          }
          self.appsSelected.forEach{app in
            print("token app \(app.self)")
          }
          self.familySelection = updatedSelection
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
        familySelection: self.familySelection,
        startTime: startTime,
        endTime: endTime,
        enable: true,
        weekdays: weekdays
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
  
  @MainActor @objc
  func createLimit(_ name: String, timeLimit: String, openLimit: String, weekdays: [Int], resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    
    let deviceActivityCenter = DeviceActivityCenter();
    
    do {
      let context = try getContext()
      
      // Create limit
      let limit = Limit(
        name: name,
        appsTokens: self.appsSelected,
        familySelection: self.familySelection,
        timeLimit: timeLimit,
        openLimit: openLimit,
        enable: true,
        weekdays: weekdays
      )
      context.insert(limit)
      try context.save()
      
      var eventsArray: [DeviceActivityEvent.Name: DeviceActivityEvent] = [:]
      
      // Create events
      try self.appsSelected.forEach{appSelected in
        let event = Event(
          limitId: limit.id,
          appToken: appSelected
        )
        context.insert(event)
        try context.save()

        // Create array with events for monitoring
        let threshold = DateComponents(minute: 1)
        let eventName = DeviceActivityEvent.Name(rawValue: "\(event.id.uuidString)-event")
        let activityEvent = DeviceActivityEvent(applications: [appSelected.self], threshold: threshold)
        
        eventsArray[eventName] = activityEvent

      }
      
      print("Events arrays: \(eventsArray)")
      
      try deviceActivityCenter.startMonitoring(
        DeviceActivityName(rawValue: "\(limit.id.uuidString)-limit"),
        during: DeviceActivitySchedule(
          intervalStart: DateComponents(hour: 0, minute: 0),
          intervalEnd: DateComponents(hour: 23, minute: 59),
          repeats: true
        ),
        events: eventsArray
      )
      
      resolve(["status": "success", "appsWithLimit": self.appsSelected.count])
    } catch {
      print("Error trying to create limit")
    }
  }
  
  @MainActor @objc
  func getLimits(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock){
    
    do {
      let context = try getContext()
      
      let fetchDescriptor = FetchDescriptor<Limit>()
      let limits = try context.fetch(fetchDescriptor)
      
      let limitArray = limits.map { limit -> [String: Any] in
        return [
            "id": limit.id.uuidString, // Asegúrate de que 'id' sea un UUID
            "title": limit.name, // Reemplaza con los campos de tu modelo
            "timeLimit": limit.timeLimit,
            "openLimit": limit.openLimit,
            "apps": limit.appsTokens.count,
            "weekdays": limit.weekdays,
            "enable": limit.enable
        ]
      }
      resolve(["status": "success", "limits" : limitArray])

    } catch {
      print("Error trying to get limits")
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
      let context = try getContext()
      
      let fetchDescriptor = FetchDescriptor<Block>()
      let blocks = try context.fetch(fetchDescriptor)
      
      let blocksArray = blocks.map { block -> [String: Any] in
        return [
            "id": block.id.uuidString, // Asegúrate de que 'id' sea un UUID
            "title": block.name, // Reemplaza con los campos de tu modelo
            "subtitle": "\(block.startTime)-\(block.endTime)",
            "apps": block.appsTokens.count,
            "weekdays": block.weekdays,
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
  
      let context = try getContext()
      
      // Stop monitoring
      var fetchDescriptor = FetchDescriptor<Block>(
        predicate: #Predicate{ $0.id == uuid }
      )
      fetchDescriptor.fetchLimit = 1
      let result = try context.fetch(fetchDescriptor)
      let block = result.first
      
      let deviceActivityCenter = DeviceActivityCenter();
      
      if block?.weekdays.count == 0 {
        try deviceActivityCenter.stopMonitoring([DeviceActivityName(rawValue: blockId)])
      } else {
        let deviceActivityNames: [DeviceActivityName] = block?.weekdays.map { weekday in DeviceActivityName(rawValue: "\(blockId)-day-\(weekday)") } ?? []
        try deviceActivityCenter.stopMonitoring(deviceActivityNames)
        print(deviceActivityNames)
      }
      
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
  func getBlock(_ blockId: String, resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    do {
      guard let uuid = UUID(uuidString: blockId) else {
        reject("invalid_uuid", "El blockId proporcionado no es un UUID válido.", nil)
        return
      }
      
      let context = try getContext()
      
      var fetchDescriptor = FetchDescriptor<Block>(
        predicate: #Predicate{ $0.id == uuid }
      )
      fetchDescriptor.fetchLimit = 1
      let result = try context.fetch(fetchDescriptor)
      let block = result.first
      
      let blockData = [
        "id": block?.id.uuidString,
        "name": block?.name,
        "startTime": block?.startTime,
        "endTime": block?.endTime,
        "apps": block?.appsTokens.count,
        "weekdays": block?.weekdays
      ] as [String : Any]

      resolve(["status": "success", "block" : blockData])
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
      let deviceActivityCenter = DeviceActivityCenter();
      
      let context = try getContext()
      
      let fetchDescriptor = FetchDescriptor<Block>(
        predicate: #Predicate { $0.id == uuid }
      )
      let result = try context.fetch(fetchDescriptor)
      let block = result.first

      block?.enable = isEnable
      
      if !isEnable {
        // Stop monitoring
        if block?.weekdays.count == 0 {
          try deviceActivityCenter.stopMonitoring([DeviceActivityName(rawValue: blockId)])
        } else {
          let deviceActivityNames: [DeviceActivityName] = block?.weekdays.map { weekday in DeviceActivityName(rawValue: "\(blockId)-day-\(weekday)") } ?? []
          try deviceActivityCenter.stopMonitoring(deviceActivityNames)
          print(deviceActivityNames)
        }
        
        let store = ManagedSettingsStore(named: ManagedSettingsStore.Name(rawValue: blockId))
        store.shield.applications = nil
      } else {
        let startTimeComponents = block?.startTime.split(separator: ":") ?? []
        let endTimeComponents = block?.endTime.split(separator: ":") ?? []
        let weekdays = block?.weekdays ?? []
        
        if weekdays.count == 0 {
          try deviceActivityCenter.startMonitoring(
            DeviceActivityName(rawValue: blockId),
            during: DeviceActivitySchedule(
              intervalStart: DateComponents(hour: Int(startTimeComponents[0]), minute: Int(startTimeComponents[1])),
              intervalEnd: DateComponents(hour: Int(endTimeComponents[0]), minute: Int(endTimeComponents[1])),
              repeats: false
            )
          )
          print("Only one time \(blockId)")
        } else {
          for weekday in weekdays {
            try deviceActivityCenter.startMonitoring(
              DeviceActivityName(rawValue: "\(blockId)-day-\(weekday)"),
              during: DeviceActivitySchedule(
                intervalStart: DateComponents(hour: Int(startTimeComponents[0]), minute: Int(startTimeComponents[1]), weekday: weekday),
                intervalEnd: DateComponents(hour: Int(endTimeComponents[0]), minute: Int(endTimeComponents[1]), weekday: weekday),
                repeats: true
              )
            )
            print("Repeat on \(weekday) \(blockId)")
          }
        }
      }
      
      try context.save()

      resolve(["status": "success", "blockId" : blockId, "isEnable": isEnable, "blockName": block?.name])
    } catch {
      print("Error updating block status")
    }
  }
  
  @MainActor @objc
  func updateBlock(_ blockId: String, name: String, startTime: String, endTime: String, weekdays: [Int], changeApps: Bool, resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    do {
      guard let uuid = UUID(uuidString: blockId) else {
        reject("invalid_uuid", "El blockId proporcionado no es un UUID válido.", nil)
        return
      }
      
      let context = try getContext()
      
      var fetchDescriptor = FetchDescriptor<Block>(
        predicate: #Predicate{ $0.id == uuid }
      )
      fetchDescriptor.fetchLimit = 1
      let result = try context.fetch(fetchDescriptor)
      let block = result.first
      
      let deviceActivityCenter = DeviceActivityCenter();
      
      if block?.weekdays.count == 0 {
        try deviceActivityCenter.stopMonitoring([DeviceActivityName(rawValue: blockId)])
      } else {
        let deviceActivityNames: [DeviceActivityName] = block?.weekdays.map { weekday in DeviceActivityName(rawValue: "\(blockId)-day-\(weekday)") } ?? []
        try deviceActivityCenter.stopMonitoring(deviceActivityNames)
        print(deviceActivityNames)
      }
      
      // Remove shield from apps
      let store = ManagedSettingsStore(named: ManagedSettingsStore.Name(rawValue: blockId))
      store.shield.applications = nil
      
      // Create again monitoring
      let startTimeComponents = startTime.split(separator: ":")
      let endTimeComponents = endTime.split(separator: ":")
      
      if weekdays.count == 0 {
        try deviceActivityCenter.startMonitoring(
          DeviceActivityName(rawValue: blockId),
          during: DeviceActivitySchedule(
            intervalStart: DateComponents(hour: Int(startTimeComponents[0]), minute: Int(startTimeComponents[1])),
            intervalEnd: DateComponents(hour: Int(endTimeComponents[0]), minute: Int(endTimeComponents[1])),
            repeats: false
          )
        )
        print("Only one time \(blockId)")
      } else {
        for weekday in weekdays {
          try deviceActivityCenter.startMonitoring(
            DeviceActivityName(rawValue: "\(blockId)-day-\(weekday)"),
            during: DeviceActivitySchedule(
              intervalStart: DateComponents(hour: Int(startTimeComponents[0]), minute: Int(startTimeComponents[1]), weekday: weekday),
              intervalEnd: DateComponents(hour: Int(endTimeComponents[0]), minute: Int(endTimeComponents[1]), weekday: weekday),
              repeats: true
            )
          )
          print("Repeat on \(weekday) \(blockId)")
        }
      }
      
      // Saves changes
      block?.name = name
      if changeApps {
        block?.appsTokens = self.appsSelected
        block?.familySelection = self.familySelection
      }
      block?.startTime = startTime
      block?.endTime = endTime
      block?.weekdays = weekdays
      
      try context.save()
      resolve(["status": "success"])
    } catch {
      reject("Error", "Could not update block", nil)
    }
    
  }
  
  @objc static func requiresMainQueueSetup() -> Bool {
      return true
  }
}

