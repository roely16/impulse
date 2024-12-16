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
    enableTimeConfiguration: Bool = true,
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
        webDomainTokens: self.websDomainSelected,
        familySelection: self.familySelection,
        timeLimit: timeLimit,
        openLimit: openLimit,
        enable: true,
        weekdays: weekdays,
        impulseTime: Int(truncating: impulseTime),
        usageWarning: Int(truncating: usageWarning),
        enableTimeConfiguration: enableTimeConfiguration
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
      
      // Create evets for webs
      try self.websDomainSelected.forEach{web in
        let event = WebEvent(
          limit: limit,
          webToken: web,
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
        let activityEvent = DeviceActivityEvent(webDomains: [web.self], threshold: threshold)
        
        eventsArray[eventName] = activityEvent
        
      }
      
      /*
       If weekdays is upper 0 then
        create monitoring with format limitId-limit-day-weekday
       else
        create monitoring with format limitId-limit
      */
      
      logger.info("Impulse: enable time configuration \(enableTimeConfiguration)")
      let listEvents = enableTimeConfiguration ? eventsArray : [:]
      
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
            events: listEvents
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
          events: listEvents
        )
      }
      
      // Control day
      if weekdays.count > 0 {
        for weekday in weekdays {

          let monitorName = Constants.monitorNameForControlDayWithFrequency(id: limit.id.uuidString, weekday: weekday)
          
          logger.info("Impulse: Create limit with weekday: \(monitorName)")
                    
          logger.info("Impulse: minutes to block \(minutesToBlock, privacy: .public) and usage warning \(usageWarning, privacy: .public)")
          
          try deviceActivityCenter.startMonitoring(
            DeviceActivityName(rawValue: monitorName),
            during: DeviceActivitySchedule(
              intervalStart: DateComponents(hour: 0, minute: 0, weekday: weekday),
              intervalEnd: DateComponents(hour: 23, minute: 59, weekday: weekday),
              repeats: true
            )
          )
          
        }
      } else {
        // Start monitoring
        let monitorName = Constants.monitorNameForControlDay(id: limit.id.uuidString)
        
        try deviceActivityCenter.startMonitoring(
          DeviceActivityName(rawValue: monitorName),
          during: DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: false
          )
        )
      }
      
      resolve(["status": "success", "appsWithLimit": self.appsSelected.count])
    } catch {
      print("Error trying to create limit \(error.localizedDescription)")
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
    enableTimeConfiguration: Bool,
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
      
      let oldTimeLimit = limit.timeLimit
      
      let oldMinutesToBlock = LimitModule.shared.getLimitTime(time: oldTimeLimit);
      let newMinutesToBlock = LimitModule.shared.getLimitTime(time: timeLimit);
      let timeLimitIncrease = newMinutesToBlock > oldMinutesToBlock
      
      logger.info("Impulse: old time limit \(oldMinutesToBlock), new time limit \(newMinutesToBlock) and is time limit increase \(timeLimitIncrease)")
      
      let changeOpenLimit = limit.openLimit != openLimit
      let requireUpdateSharedDefaults = changeOpenLimit
      
      let openLimitValue = Int(openLimit) ?? 0
      let openLimitSavedValue = Int(limit.openLimit) ?? 0
      
      let openLimitIncrease = openLimitValue > openLimitSavedValue
      
      limit.name = name
      limit.timeLimit = timeLimit
      limit.openLimit = openLimit
      limit.enableTimeConfiguration = enableTimeConfiguration
      
      // Apps
      let addedApps = self.appsSelected.subtracting(limit.appsTokens)
      let removedApps = limit.appsTokens.subtracting(self.appsSelected)
      
      logger.info("Impulse: apps added: \(addedApps.count, privacy: .public) and apps deleted \(removedApps.count, privacy: .public)")

      // Sites
      let addedSites = self.websDomainSelected.subtracting(limit.webDomainTokens)
      let removedSites = limit.webDomainTokens.subtracting(self.websDomainSelected)
      
      logger.info("Impulse: sites added: \(addedSites.count, privacy: .public) and sites deleted \(removedSites.count, privacy: .public)")
      
      let context = try LimitModule.shared.getContext()
            
      // Create events for each new app or remove data for each deleted app
      addedApps.forEach{app in
        let event = AppEvent(
          limit: limit,
          appToken: app,
          opens: 0,
          status: .warning
        )
        context.insert(event)
      }
            
      removedApps.forEach{app in
        limit.appsEvents.forEach{event in
          if event.appToken == app {
            let managedSettingsName = Constants.managedSettingsName(eventId: event.id.uuidString)
            limitUtils.clearManagedSettingsByEvent(eventId: event.id.uuidString)
            monitorUitls.stopMonitoring(monitorName: managedSettingsName)
            
            context.delete(event)
          }
        }
      }
      
      try context.save()

      // Create events for each new site or remove data for each deleted site
      addedSites.forEach{site in
        let event = WebEvent(
          limit: limit,
          webToken: site,
          opens: 0,
          status: .warning
        )
        context.insert(event)
      }
            
      removedSites.forEach{site in
        limit.websEvents.forEach{event in
          if event.webToken == site {
            let managedSettingsName = Constants.managedSettingsName(eventId: event.id.uuidString)
            limitUtils.clearManagedSettingsByEvent(eventId: event.id.uuidString)
            monitorUitls.stopMonitoring(monitorName: managedSettingsName)
            
            context.delete(event)
          }
        }
      }
      
      try context.save()
      
      if changeApps {
        limit.appsTokens = self.appsSelected
        limit.webDomainTokens = self.websDomainSelected
        limit.familySelection = self.familySelection
      }
      limit.weekdays = weekdays
      limit.impulseTime = Int(truncating: impulseTime)
      limit.usageWarning = Int(truncating: usageWarning)
      
      try limit.modelContext?.save()
      
      // Find if apps have been changed
      
      if requireUpdateSharedDefaults || timeLimitIncrease {
        logger.info("Impulse: requiere update shared defaults")
        
        // Update shared defaults by apps
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
          
          let hasReachedOpenLimit = openLimitValue > 0 && openLimitValue <= event.opens
          
          if event.status == .block && (openLimitIncrease || timeLimitIncrease) && !hasReachedOpenLimit {
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
          } else if event.status == .block && !enableTimeConfiguration {
            logger.info("Impulse: remove lock app status and update to warning")
            
            sharedDefaultManager.deleteSharedDefaultsByToken(token: .application(event.appToken), type: .block)
            event.status = .warning
            try event.modelContext?.save()
          }
          
        }
        
        // Update shared defaults by webs
        try limit.websEvents.forEach{event in
          let shieldData = [
            "limitName": limit.name,
            "impulseTime": limit.impulseTime,
            "openLimit": limit.openLimit,
            "shieldButtonEnable": true,
            "opens": event.opens,
            "eventId": event.id.uuidString
          ]
          
          let sharedDefaultKey = sharedDefaultManager.createTokenKeyString(token: .webDomain(event.webToken), type: .limit)
          try sharedDefaultManager.writeSharedDefaults(forKey: sharedDefaultKey, data: shieldData)
          
          logger.info("Impulse: web event status \(event.status.rawValue, privacy: .public)")
          
          let hasReachedOpenLimit = openLimitValue <= event.opens
          
          logger.info("Impulse: event status: \(event.status.rawValue), open limit increase: \(openLimitIncrease), time limit increase \(timeLimitIncrease) and has reached open limit \(hasReachedOpenLimit)")
          
          if event.status == .block && (openLimitIncrease || timeLimitIncrease) && !hasReachedOpenLimit {
            logger.info("Impulse: remove lock web status and update to warning")
            
            sharedDefaultManager.deleteSharedDefaultsByToken(token: .webDomain(event.webToken), type: .block)
            event.status = .warning
            try event.modelContext?.save()
          } else if event.status == .warning && hasReachedOpenLimit {
            logger.info("Impulse: block webs because the new open limit is less than the current open limit.")
            
            let shieldBlock = [
              "blockName": limit.name
            ]
            
            let sharedDefaultKey = sharedDefaultManager.createTokenKeyString(token: .webDomain(event.webToken), type: .block)
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
      
      let oldWeekDays = block?.weekdays
      
      block?.name = name
      
      logger.info("Impulse: change apps \(changeApps)")
      
      if changeApps {
        block?.appsTokens = self.appsSelected
        block?.webDomainTokens = self.websDomainSelected
        block?.familySelection = self.familySelection
      }
      block?.startTime = startTime
      block?.endTime = endTime
      block?.weekdays = weekdays

      try block?.modelContext?.save()

      let deviceActivityCenter = DeviceActivityCenter();
      
      let monitorName = Constants.monitorName(id: blockId, type: .block)
      deviceActivityCenter.stopMonitoring([DeviceActivityName(rawValue: monitorName)])
      
      if oldWeekDays?.count ?? 0 > 0 {

        oldWeekDays?.forEach{weekday in
          let monitorName = Constants.monitorNameWithFrequency(id: blockId, weekday: weekday, type: .block)
          
          logger.info("Impulse: monitor name \(monitorName)")
          
          deviceActivityCenter.stopMonitoring([DeviceActivityName(rawValue: monitorName)])
        }
        
      }
      
      // Create again monitoring
      let startTimeComponents = startTime.split(separator: ":")
      let endTimeComponents = endTime.split(separator: ":")
      
      let monitorUtils = MonitorUtils()
      
      let activitySchedule = DeviceActivitySchedule(
        intervalStart: DateComponents(hour: Int(startTimeComponents[0]), minute: Int(startTimeComponents[1])),
        intervalEnd: DateComponents(hour: Int(endTimeComponents[0]), minute: Int(endTimeComponents[1])),
        repeats: false
      )
      
      monitorUtils.startMonitoring(id: blockId, duration: activitySchedule, weekdays: weekdays)
      
      resolve(["status": "success"])
    } catch {
      reject("Error", "Could not update block", nil)
    }
    
  }
  
  @objc static func requiresMainQueueSetup() -> Bool {
      return true
  }
}

