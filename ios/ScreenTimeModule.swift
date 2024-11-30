import Foundation
import FamilyControls
import DeviceActivity
import ManagedSettings
import React
import SwiftUI
import SwiftData

@objc(ScreenTimeModule)
class ScreenTimeModule: NSObject {
  
  let sharedDefaults = UserDefaults(suiteName: "group.com.impulsecontrolapp.impulse.share")

  var appsSelected: Set<ApplicationToken> = []
  var websDomainSelected: Set<WebDomainToken> = []
  var familySelection: FamilyActivitySelection = FamilyActivitySelection()
  
  private var container: ModelContainer?
  private var logger = Logger()
  private var encoder = JSONEncoder()
  
  enum TokenType {
      case application(ApplicationToken)
      case webDomain(WebDomainToken)
  }
  
  override init() {
    super.init()
    do {
      container = try ModelConfigurationManager.makeConfiguration()
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
  
  func handleAuthorizationError(
    _ errorCode: String? = nil,
    error: Error,
    reject: @escaping RCTPromiseRejectBlock
  ) {
      let finalErrorCode = errorCode ?? "FAILED"
      let errorMessage = "Failed to request authorization: \(error.localizedDescription)"
      reject(finalErrorCode, errorMessage, error)
  }
    
  func createTokenString(token: TokenType) -> String{
    do {
      let tokenData: Data
      switch token {
      case .application(let appToken):
          tokenData = try encoder.encode(appToken)
      case .webDomain(let webToken):
          tokenData = try encoder.encode(webToken)
      }
      let tokenString = String(data: tokenData, encoding: .utf8)
      return tokenString ?? ""
    } catch {
      logger.error("Impulse: Error trying to enconde app or web token")
    }
    return ""
  }
  
  @MainActor @objc
  func requestAuthorization(
    _ testBlockName: String = "",
    resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    if #available(iOS 16.0, *) {
      Task {
        do {
          try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
          let context = try getContext()
          let block = Block(
            name: "Bloqueo de prueba",
            appsTokens: [],
            webDomainTokens: [],
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
  func showAppPicker(
    _ isFirstSelection: Bool,
    blockId: String = "",
    limitId: String = "",
    saveButtonText: String = "",
    titleText: String = "",
    resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
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
          self.appsSelected = updatedSelection.applicationTokens
          self.websDomainSelected = updatedSelection.webDomainTokens
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
  func createBlock(
    _ name: String,
    startTime: String,
    endTime: String,
    weekdays: [Int],
    resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {    
    do {
      
      let context = try getContext()

      let block = Block(
        name: name,
        appsTokens: self.appsSelected,
        webDomainTokens: self.websDomainSelected,
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
      let monitorUtils = MonitorUtils()
      
      let activityName = block.id.uuidString
      
      let activitySchedule = DeviceActivitySchedule(
        intervalStart: DateComponents(hour: Int(startTimeComponents[0]), minute: Int(startTimeComponents[1])),
        intervalEnd: DateComponents(hour: Int(endTimeComponents[0]), minute: Int(endTimeComponents[1])),
        repeats: false
      )
      
      monitorUtils.startMonitoring(activityName: activityName, duration: activitySchedule, weekdays: weekdays)
      
      resolve(["status": "success", "appsBlocked": self.appsSelected.count])

    } catch {
      reject("Error", "Error trying to create block: \(error.localizedDescription)", error)
    }
  }
  
  @MainActor @objc
  func createLimit(
    _ name: String, 
    timeLimit: String,
    openLimit: String,
    weekdays: [Int],
    enableImpulseMode: Bool = false,
    impulseTime: NSNumber = 0,
    usageWarning: NSNumber = 0,
    resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    
    let deviceActivityCenter = DeviceActivityCenter();
    
    do {
      logger.info("Impulse: start create limit")
      let context = try getContext()
      
      // Save limit on store
      let limit = Limit(
        name: name,
        appsTokens: self.appsSelected,
        familySelection: self.familySelection,
        timeLimit: timeLimit,
        openLimit: openLimit,
        enable: true,
        weekdays: weekdays,
        impulseTime: Int(truncating: impulseTime),
        usageWarning: Int(truncating: usageWarning)
      )
      context.insert(limit)
      try context.save()
      
      // Create event for each app or web
      var eventsArray: [DeviceActivityEvent.Name: DeviceActivityEvent] = [:]
      
      let minutesToBlock = LimitModule.shared.getLimitTime(time: timeLimit);
      
      // Create events
      try self.appsSelected.forEach{appSelected in
        let event = AppEvent(
          limit: limit,
          appToken: appSelected,
          opens: 0
        )
        context.insert(event)
        try context.save()

        let eventRawName = "\(event.id.uuidString)-limit-time"
        
        logger.info("Impulse: create event \(eventRawName)")
        
        // Create array with events for monitoring
        let threshold = DateComponents(minute: minutesToBlock)
        let eventName = DeviceActivityEvent.Name(rawValue: eventRawName)
        
        // This limite represent the principal limit time
        let activityEvent = DeviceActivityEvent(applications: [appSelected.self], threshold: threshold)
        
        eventsArray[eventName] = activityEvent
        
        // Create share data for each app
        let tokenString = createTokenString(token: .application(appSelected))
        let sharedDefaultKey = "\(tokenString)-limit"
        
        logger.info("Impulse: create shared default with key \(sharedDefaultKey)")
        
        let shieldConfigurationData = [
          "limitName": limit.name,
          "impulseTime": limit.impulseTime,
          "openLimit": limit.openLimit,
          "usageWarning": limit.usageWarning,
          "shieldButtonEnable": true,
          "eventId": event.id.uuidString,
          "startBlocking": true,
          "opens": event.opens
        ]
        
        let data = try JSONSerialization.data(withJSONObject: shieldConfigurationData, options: [])
        sharedDefaults?.set(data, forKey: sharedDefaultKey)
        
      }
      
      print("Events arrays: \(eventsArray)")
      
      /*
       If weekdays is upper 0 then
        create monitoring with format limitId-limit-day-weekday
       else
        create monitoring with format limitId-limit
      */
      
      // Validate if frecuency exist
      if weekdays.count > 0 {
        logger.info("Create frecuency")
        for weekday in weekdays {
          let monitoringName = "\(limit.id.uuidString)-limit-day-\(weekday)"

          logger.info("Impulse: Create limit with weekday: \(monitoringName)")
          
          try deviceActivityCenter.startMonitoring(
            DeviceActivityName(rawValue: monitoringName),
            during: DeviceActivitySchedule(
              intervalStart: DateComponents(hour: 0, minute: 0, weekday: weekday),
              intervalEnd: DateComponents(hour: 23, minute: 59, weekday: weekday),
              repeats: true
            ),
            events: eventsArray
          )
        }
      } else {
        // Start monitoring
        try deviceActivityCenter.startMonitoring(
          DeviceActivityName(rawValue: "\(limit.id.uuidString)-limit"),
          during: DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: false
          ),
          events: eventsArray
        )
      }
      
      resolve(["status": "success", "appsWithLimit": self.appsSelected.count])
    } catch {
      print("Error trying to create limit")
    }
  }
  
  @MainActor @objc
  func updateLimit(
    _ limitId: String,
    name: String,
    timeLimit: String,
    openLimit: String,
    weekdays: [Int],
    changeApps: Bool,
    enableImpulseMode: Bool = false,
    impulseTime: NSNumber = 0,
    usageWarning: NSNumber = 0,
    resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ){
    do {
      guard let uuid = UUID(uuidString: limitId) else {
        reject("invalid_uuid", "El blockId proporcionado no es un UUID válido.", nil)
        return
      }
      // Call disable limit without change status
      LimitModule.shared.disableLimit(limitId: uuid, updateStore: false)

      // Save changes on store
      let limit = LimitModule.shared.findLimit(limitId: uuid)
      limit?.name = name
      limit?.timeLimit = timeLimit
      limit?.openLimit = openLimit
      if changeApps {
        limit?.appsTokens = self.appsSelected
        limit?.familySelection = self.familySelection
      }
      limit?.weekdays = weekdays
      limit?.impulseTime = Int(truncating: impulseTime)
      limit?.usageWarning = Int(truncating: usageWarning)
      
      try limit?.modelContext?.save()
      
      // Delete an recreate events for limit with new apps
      if changeApps {
        let context = try getContext()

        limit?.appsEvents.forEach{event in
          context.delete(event)
        }
        // Create events
        try self.appsSelected.forEach{appSelected in
          let event = AppEvent(
            limit: limit!,
            appToken: appSelected
          )
          context.insert(event)
          try context.save()
        }
      }
      
      // Enable limit again with the last changes
      LimitModule.shared.enableLimit(limitId: uuid, updateStore: false)
      resolve(["status": "success"])
    } catch {
      logger.error("Error trying to update limit")
    }
  }
  
  @MainActor @objc
  func updateBlock(
    _ blockId: String,
    name: String,
    startTime: String,
    endTime: String,
    weekdays: [Int],
    changeApps: Bool,
    resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
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
        deviceActivityCenter.stopMonitoring([DeviceActivityName(rawValue: blockId)])
      } else {
        let deviceActivityNames: [DeviceActivityName] = block?.weekdays.map { weekday in DeviceActivityName(rawValue: "\(blockId)-day-\(weekday)") } ?? []
        deviceActivityCenter.stopMonitoring(deviceActivityNames)
      }
      
      // Remove shield from apps
      let store = ManagedSettingsStore(named: ManagedSettingsStore.Name(rawValue: blockId))
      store.shield.applications = nil
      store.shield.webDomains = nil
      
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
        block?.webDomainTokens = self.websDomainSelected
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

