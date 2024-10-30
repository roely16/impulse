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
  private var logger = Logger()
  
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
  func showAppPicker(_ isFirstSelection: Bool, blockId: String = "", limitId: String = "", saveButtonText: String = "", titleText: String = "", resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    DispatchQueue.main.async {
      
      if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let window = scene.windows.first {
        
        let pickerView = ActivityPickerView(
          isFirstSelection: isFirstSelection,
          blockId: blockId,
          limitId: limitId,
          saveButtonText: saveButtonText,
          titleText: titleText
        ) { updatedSelection in
          let applications = updatedSelection.applications
          self.appsSelected = updatedSelection.applicationTokens
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
  
  func getLimitTime(time: String = "") -> Int? {
    let components = time.split(separator: ":")
    if let hours = Int(components[0]), let minutes = Int(components[1]) {
      let totalMinutes = (hours * 60) + minutes
      return totalMinutes
    } else {
      print("Invalid format")
      return nil
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
      
      let minutesToBlock = getLimitTime(time: timeLimit);
      
      // Create events
      try self.appsSelected.forEach{appSelected in
        let event = Event(
          limit: limit,
          appToken: appSelected
        )
        context.insert(event)
        try context.save()

        // Create array with events for monitoring
        let threshold = DateComponents(minute: minutesToBlock)
        let eventName = DeviceActivityEvent.Name(rawValue: "\(event.id.uuidString)-event")
        let activityEvent = DeviceActivityEvent(applications: [appSelected.self], threshold: threshold)
        
        eventsArray[eventName] = activityEvent

      }
      
      print("Events arrays: \(eventsArray)")
      
      // Start monitoring
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
  
  @MainActor
  func disableLimit(limitId: UUID, updateStore: Bool = false){
    do {
      // Remove shields
      let limit = findLimit(limitId: limitId)
      limit?.events.forEach{event in
        let store = ManagedSettingsStore(named: ManagedSettingsStore.Name(rawValue: "event-\(event.id.uuidString)"))
        store.shield.applications = nil
      }
      
      // Stop monitoring
      let deviceActivityCenter = DeviceActivityCenter();
      deviceActivityCenter.stopMonitoring([DeviceActivityName(rawValue: "\(String(describing: limitId.uuidString))-limit")])
      
      // Update limit status
      if updateStore {
        limit?.enable = false
        try limit?.modelContext?.save()
      }
      
    } catch {
      print("Error trying to disable limit")
    }
  }
  
  @MainActor
  func enableLimit(limitId: UUID, updateStore: Bool = false){
    do {
      
      // Get limit
      let limit = findLimit(limitId: limitId)
      
      // Get minutes to block for each event
      let minutesToBlock = getLimitTime(time: limit?.timeLimit ?? "");
      
      var eventsArray: [DeviceActivityEvent.Name: DeviceActivityEvent] = [:]
      limit?.events.forEach{event in
        if minutesToBlock != nil {
          let threshold = DateComponents(minute: minutesToBlock)
          let eventName = DeviceActivityEvent.Name(rawValue: "\(event.id.uuidString)-event")
          let activityEvent = DeviceActivityEvent(applications: [event.appToken], threshold: threshold)
          
          eventsArray[eventName] = activityEvent
        }
      }
      
      // Start monitoring
      let deviceActivityCenter = DeviceActivityCenter();
      
      try deviceActivityCenter.startMonitoring(
        DeviceActivityName(rawValue: "\(limitId.uuidString)-limit"),
        during: DeviceActivitySchedule(
          intervalStart: DateComponents(hour: 0, minute: 0),
          intervalEnd: DateComponents(hour: 23, minute: 59),
          repeats: true
        ),
        events: eventsArray
      )
      
      // Update limit status
      if updateStore {
        limit?.enable = true
        try limit?.modelContext?.save()
      }
    } catch {
      print("Error trying to enable limit")
    }
  }
  
  @MainActor
  func findLimit(limitId: UUID) -> Limit? {
    do {
      let context = try getContext()
      
      // Find limit
      let fetchDescriptor = FetchDescriptor<Limit>(
        predicate: #Predicate{ $0.id == limitId }
      )
      let limit = try context.fetch(fetchDescriptor)
      return limit.first
    } catch {
      print("Error trying to find limit with events")
      return nil
    }
  }
  
  @MainActor @objc
  func deleteLimit(_ limitId: String = "", resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock){
    do {
      guard let uuid = UUID(uuidString: limitId) else {
        reject("invalid_uuid", "The limit id is not a valid UUID", nil)
        return
      }
      
      // Get events
      let limit = findLimit(limitId: uuid)
      let context = try getContext()
      
      limit?.events.forEach{event in
        // Remove restrictions for every app
        let store = ManagedSettingsStore(named: ManagedSettingsStore.Name(rawValue: "event-\(event.id)"))
        store.shield.applications = nil
      }
      
      // Stop monitoring
       let deviceActivityCenter = DeviceActivityCenter();
       deviceActivityCenter.stopMonitoring([DeviceActivityName(rawValue: "\(uuid)-limit")])
            
      // Delete limit and events
      try context.delete(model: Limit.self, where: #Predicate { $0.id == uuid })
      resolve(["status": "success"])
    } catch {
      print("Error trying to delete limit")
    }
  }
  
  @MainActor @objc
  func updateLimitStatus(_ limitId: String = "", enable: Bool, resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    guard let uuid = UUID(uuidString: limitId) else {
      reject("invalid_uuid", "The limit id is not a valid UUID", nil)
      return
    }
    
    if !enable {
      // Disable limint and remove events shield
      print("Disable limit")
      disableLimit(limitId: uuid, updateStore: true)
    } else {
      // Enable limit and events again
      print("Enable limit")
      enableLimit(limitId: uuid, updateStore: true)
    }
    
    resolve(["status": "success"])
  }
  
  @MainActor @objc
  func getLimitDetail(_ limitId: String, resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock){
    guard let uuid = UUID(uuidString: limitId) else {
      reject("invalid_uuid", "The limit id is not a valid UUID", nil)
      return
    }
    
    let limit = findLimit(limitId: uuid)
    
    let limitData = [
      "id": limit?.id.uuidString,
      "name": limit?.name,
      "timeLimit": limit?.timeLimit,
      "openTime": limit?.openLimit,
      "apps": limit?.appsTokens.count,
      "weekdays": limit?.weekdays
    ] as [String : Any]
    
    resolve(["status": "success", "limit" : limitData])
  }
  
  @MainActor @objc
  func updateLimit(_ limitId: String, name: String, timeLimit: String, openLimit: String, weekdays: [Int], changeApps: Bool, resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock){
    do {
      guard let uuid = UUID(uuidString: limitId) else {
        reject("invalid_uuid", "El blockId proporcionado no es un UUID válido.", nil)
        return
      }
      // Call disable limit without change status
      disableLimit(limitId: uuid, updateStore: false)

      // Save changes on store
      let limit = findLimit(limitId: uuid)
      limit?.name = name
      limit?.timeLimit = timeLimit
      limit?.openLimit = openLimit
      if changeApps {
        limit?.appsTokens = self.appsSelected
        limit?.familySelection = self.familySelection
      }
      limit?.weekdays = weekdays
      
      try limit?.modelContext?.save()
      
      // Delete an recreate events for limit with new apps
      if changeApps {
        let context = try getContext()

        limit?.events.forEach{event in
          context.delete(event)
        }
        // Create events
        try self.appsSelected.forEach{appSelected in
          let event = Event(
            limit: limit!,
            appToken: appSelected
          )
          context.insert(event)
          try context.save()
        }
      }
      
      // Enable limit again with the last changes
      enableLimit(limitId: uuid, updateStore: false)
      resolve(["status": "success"])
    } catch {
      logger.error("Error trying to update limit")
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

