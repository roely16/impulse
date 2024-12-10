import Foundation
import FamilyControls
import DeviceActivity
import ManagedSettings
import React
import SwiftUI
import SwiftData

@objc(ScreenTimeModule)
class ScreenTimeModule: NSObject {
  
  let sharedDefaults = UserDefaults(suiteName: Constants.SHARED_DEFAULT_GROUP)

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
            
      let activitySchedule = DeviceActivitySchedule(
        intervalStart: DateComponents(hour: Int(startTimeComponents[0]), minute: Int(startTimeComponents[1])),
        intervalEnd: DateComponents(hour: Int(endTimeComponents[0]), minute: Int(endTimeComponents[1])),
        repeats: false
      )
      
      monitorUtils.startMonitoring(id: block.id.uuidString, duration: activitySchedule, weekdays: weekdays)
      
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
          opens: 0,
          status: .warning
        )
        context.insert(event)
        try context.save()

        let eventRawName = Constants.eventNameForLimitTime(eventId: event.id.uuidString)
        
        logger.info("Impulse: create event \(eventRawName)")
        
        // Create array with events for monitoring
        let threshold = DateComponents(minute: minutesToBlock)
        let eventName = DeviceActivityEvent.Name(rawValue: eventRawName)
        
        // This limite represent the principal limit time
        let activityEvent = DeviceActivityEvent(applications: [appSelected.self], threshold: threshold)
        
        eventsArray[eventName] = activityEvent
        
      }
      
      /*
       If weekdays is upper 0 then
        create monitoring with format limitId-limit-day-weekday
       else
        create monitoring with format limitId-limit
      */
      
      // Validate if frecuency exist
      if weekdays.count > 0 {
        for weekday in weekdays {

          let monitorName = Constants.monitorNameWithFrequency(id: limit.id.uuidString, weekday: weekday, type: .limit)
          
          logger.info("Impulse: Create limit with weekday: \(monitorName)")
                    
          logger.info("Impulse: minutes to block \(minutesToBlock, privacy: .public) and usage warning \(usageWarning, privacy: .public)")
          
          try deviceActivityCenter.startMonitoring(
            DeviceActivityName(rawValue: monitorName),
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
        let monitorName = Constants.monitorName(id: limit.id.uuidString, type: .limit)
        
        try deviceActivityCenter.startMonitoring(
          DeviceActivityName(rawValue: monitorName),
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
    impulseTime: NSNumber = 0,
    usageWarning: NSNumber = 0,
    resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    do {
      guard let uuid = UUID(uuidString: limitId) else {
        reject("invalid_uuid", "El blockId proporcionado no es un UUID válido.", nil)
        return
      }
      
      logger.info("Impulse: start edit limit")
      
      let sharedDefaultManager = SharedDefaultsManager()
      let limitUtils = LimitUtils()
      let monitorUitls = MonitorUtils()
            
      // Save changes on store
      let limit = LimitModule.shared.findLimit(limitId: uuid)
      
      guard let limit = limit else {
          print("Error: limit es nil")
          return
      }
      
      let changeOpenLimit = limit.openLimit != openLimit
      let requireUpdateSharedDefaults = changeOpenLimit
      
      let openLimitValue = Int(openLimit) ?? 0
      let openLimitSavedValue = Int(limit.openLimit) ?? 0
      
      let openLimitIncrease = openLimitValue > openLimitSavedValue
      // let openLimitDecrease = openLimitValue < openLimitSavedValue
      
      limit.name = name
      limit.timeLimit = timeLimit
      limit.openLimit = openLimit
            
      let addedApps = self.appsSelected.subtracting(limit.appsTokens)
      let removedApps = limit.appsTokens.subtracting(self.appsSelected)
      
      logger.info("Impulse: apps added: \(addedApps.count, privacy: .public) and apps deleted \(removedApps.count, privacy: .public)")

      let context = try LimitModule.shared.getContext()
      
      logger.info("Impulse: context \(String(describing: context))")
      
      addedApps.forEach{app in
        let event = AppEvent(
          limit: limit,
          appToken: app,
          opens: 0,
          status: .warning
        )
        context.insert(event)
      }
      
      try context.save()
      context.processPendingChanges()
      
      removedApps.forEach{app in
        
        limit.appsEvents.forEach{event in
          if event.appToken == app {
            let managedSettingsName = Constants.managedSettingsName(eventId: event.id.uuidString)
            limitUtils.clearManagedSettingsByEvent(event: event)
            monitorUitls.stopMonitoring(monitorName: managedSettingsName)
            
            context.delete(event)
          }
        }
                
      }
            
      if changeApps {
        limit.appsTokens = self.appsSelected
        limit.familySelection = self.familySelection
      }
      limit.weekdays = weekdays
      limit.impulseTime = Int(truncating: impulseTime)
      limit.usageWarning = Int(truncating: usageWarning)
      
      try limit.modelContext?.save()
      
      // Find if apps have been changed
      
      if requireUpdateSharedDefaults {
        logger.info("Impulse: requiere update shared defaults")
        
        try limit.appsEvents.forEach{event in
          let shieldData = [
            "limitName": limit.name,
            "impulseTime": limit.impulseTime,
            "openLimit": limit.openLimit,
            "shieldButtonEnable": true,
            "opens": event.opens,
            "eventId": event.id.uuidString
          ]
          
          let sharedDefaultKey = sharedDefaultManager.createTokenKeyString(token: .application(event.appToken), type: .limit)
          try sharedDefaultManager.writeSharedDefaults(forKey: sharedDefaultKey, data: shieldData)
          
          logger.info("Impulse: app event status \(event.status.rawValue, privacy: .public)")
          
          let hasReachedOpenLimit = openLimitValue <= event.opens
          
          if event.status == .block && openLimitIncrease {
            logger.info("Impulse: remove lock app status and update to warning")
            
            sharedDefaultManager.deleteSharedDefaultsByToken(token: .application(event.appToken), type: .block)
            event.status = .warning
            try event.modelContext?.save()
          } else if event.status == .warning && hasReachedOpenLimit {
            logger.info("Impulse: block apps because the new open limit is less than the current open limit.")
            
            let shieldBlock = [
              "blockName": limit.name
            ]
            
            let sharedDefaultKey = sharedDefaultManager.createTokenKeyString(token: .application(event.appToken), type: .block)
            try sharedDefaultManager.writeSharedDefaults(forKey: sharedDefaultKey, data: shieldBlock)
            
            event.status = .block
            try event.modelContext?.save()
          }
          
        }
      }
      
      let limitModule = LimitModule.shared
      limitModule.enableLimit(limitId: uuid, updateStore: false)
      
      resolve(["status": "success"])
    } catch let error as NSError {
      logger.error("Impulse: error trying to update limit \(error.debugDescription, privacy: .public)")
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

