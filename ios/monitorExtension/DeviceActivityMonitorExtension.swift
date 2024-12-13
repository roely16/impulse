import DeviceActivity
import os.log
import UserNotifications
import SwiftData
import ManagedSettings
import Foundation

let sharedDefaults = UserDefaults(suiteName: "group.com.impulsecontrolapp.impulse.share")

class DeviceActivityMonitorExtension: DeviceActivityMonitor {
  
  private var block: Block?
  private var limit: Limit?
  private var eventModel: AppEvent?
  private var webEventModel: WebEvent?
  
  private enum EventType {
    case app
    case web
  }
  private var typeOfEvent: EventType = .app
  private var logger: Logger = Logger()
  private var container: ModelContainer
  
  override init() {
    do {
      container = try ModelConfigurationManager.makeConfiguration()
    } catch {
      fatalError("Error initializing ModelContainer: \(error)")
    }
    super.init()
  }
  
  @MainActor func getBlock(blockId: String){
    do {
      guard let uuid = UUID(uuidString: blockId) else {
        return
      }

      let context = container.mainContext
      let fetchDescriptor = FetchDescriptor<Block>(
        predicate: #Predicate{ $0.id == uuid }
      )
      let result = try context.fetch(fetchDescriptor)
      block = result.first
    } catch {
      print("Error al obtener los blocks")
    }
  }
  
  @MainActor func getLimit(limitId: String) throws {
    do {
      guard let uuid = UUID(uuidString: limitId) else {
        throw NSError(domain: "Invalid UUID", code: 1, userInfo: nil)
      }

      let context = container.mainContext
      let fetchDescriptor = FetchDescriptor<Limit>(
        predicate: #Predicate{ $0.id == uuid }
      )
      let result = try context.fetch(fetchDescriptor)
      limit = result.first
    } catch {
      throw error
    }
  }
  
  @MainActor func getEvent(eventId: String) throws {
    do {
      guard let uuid = UUID(uuidString: eventId) else {
        throw NSError(domain: "Invalid UUID", code: 1, userInfo: nil)
      }

      let context = container.mainContext
      let fetchDescriptor = FetchDescriptor<AppEvent>(
        predicate: #Predicate{ $0.id == uuid }
      )
      if let appEvent = try context.fetch(fetchDescriptor).first {
        eventModel = appEvent
        self.typeOfEvent = .app
        return
      }
      
      let webFetchDescriptor = FetchDescriptor<WebEvent>(
        predicate: #Predicate{ $0.id == uuid }
      )
      if let webEvent = try context.fetch(webFetchDescriptor).first {
        webEventModel = webEvent
        self.typeOfEvent = .web
        return
      }
      
    } catch {
      throw error
    }
  }
  
  @MainActor func saveLimitHistory(){
    do {
      let context = container.mainContext
      // Save history
      let history = AppEventHistory(
        event: eventModel!,
        status: .warning
      )
      context.insert(history)
      try context.save()
    } catch {
      print("Error trying to save limit history")
    }
  }
  
  func extractLimitId(from activityRawValue: String) -> String {
      let limitIdentifier = "-limit"

      // Verifica si el string contiene el identificador
      if let range = activityRawValue.range(of: limitIdentifier) {
        // Si se encuentra, extrae la parte anterior
        return String(activityRawValue[..<range.lowerBound])
      }
      
      // Si no se encuentra, devolver el string original
      return activityRawValue
  }
  
  func extractLimitIdByControlDay(from activityRawValue: String) -> String {
    let limitIdentifier = Constants.MONITOR_LIMIT_CONTROL_DAY

      // Verifica si el string contiene el identificador
      if let range = activityRawValue.range(of: limitIdentifier) {
        // Si se encuentra, extrae la parte anterior
        return String(activityRawValue[..<range.lowerBound])
      }
      
      // Si no se encuentra, devolver el string original
      return activityRawValue
  }
  
  func extractEventId(from eventRawValue: String) -> String {
    let identifiers = [
      Constants.EVENT_MANAGED_SETTINGS_STORE_IDENTIFIER,
      Constants.LIMIT_TIME_EVENT_NAME
    ]
    
    if let range = identifiers.compactMap({ eventRawValue.range(of: $0) }).sorted(by: { $0.lowerBound < $1.lowerBound }).first {
      return String(eventRawValue[..<range.lowerBound])
    }
    
    return eventRawValue
  }
  
  func checkIfIsLimitTime(string: String) -> Bool {
      return string.contains(Constants.LIMIT_TIME_EVENT_NAME)
  }
  
  func findLimitByActiviyId(activiyId: String = "") async {
    logger.info("Impulse: interval did start, find limit info")
    let limitId = extractLimitId(from: activiyId)
    logger.info("Impulse: limit id \(limitId, privacy: .public)")
    
    do {
      try await getLimit(limitId: limitId)
    } catch {
      logger.error("Impulse: error trying to find limit by activity id")
    }
  }
  
  func findLimitByActiviyInControlDay(activiyId: String = "") async {
    logger.info("Impulse: interval did start, find limit info")
    let limitId = extractLimitIdByControlDay(from: activiyId)
    logger.info("Impulse: limit id \(limitId, privacy: .public)")
    
    do {
      try await getLimit(limitId: limitId)
    } catch {
      logger.error("Impulse: error trying to find limit by activity id")
    }
  }
  
  func getLimitIdentifier(activiyId: String = "") -> String? {
    logger.info("Impulse: detect kind of limit")
    
    // Buscar la posición de "-limit"
    guard let range = activiyId.range(of: "-limit") else {
       return nil
    }
    
    // Obtener la porción del string desde "-limit"
    return String(activiyId[range.lowerBound...])
  }
  
  override func intervalDidStart(for activity: DeviceActivityName) {
    super.intervalDidStart(for: activity)
    Task {
      logger.info("Impulse: interval did start for activity \(activity.rawValue, privacy: .public)")
      let sharedDefaultManager = SharedDefaultsManager()
      var shieldConfigurationData: [String: Any] = [:]
      var sharedDefaultKey = ""
      
      if activity.rawValue.lowercased().contains(Constants.LIMIT_MONITOR_NAME) {
        let limitId = Constants.extractIdForLimit(from: activity.rawValue)
        logger.info("Impulse: limit id \(limitId, privacy: .public)")
        
        do {
          try await getLimit(limitId: limitId)
          
          // Apps
          try limit?.appsEvents.forEach{event in
            logger.info("Impulse: create managed settings store for app event \(event.id, privacy: .public)")
            
            if event.status == .block {
              shieldConfigurationData = [
                "blockName": event.limit?.name ?? ""
              ]
              sharedDefaultKey = sharedDefaultManager.createTokenKeyString(token: .application(event.appToken), type: .block)
            } else {
              shieldConfigurationData = [
                "limitName": limit?.name ?? "",
                "impulseTime": limit?.impulseTime ?? "",
                "openLimit": limit?.openLimit ?? "",
                "shieldButtonEnable": true,
                "opens": event.opens,
                "eventId": event.id.uuidString
              ]
              
              sharedDefaultKey = sharedDefaultManager.createTokenKeyString(token: .application(event.appToken), type: .limit)
            }
        
            try sharedDefaultManager.writeSharedDefaults(forKey: sharedDefaultKey, data: shieldConfigurationData)
            
            let managedSettingsName = Constants.managedSettingsName(eventId: event.id.uuidString)
            let store = ManagedSettingsStore(named: ManagedSettingsStore.Name(rawValue: managedSettingsName))
            store.shield.applications = [event.appToken]
          }
          
          // Webs
          try limit?.websEvents.forEach{event in
            logger.info("Impulse: create managed settings store for app event \(event.id, privacy: .public)")
            
            if event.status == .block {
              shieldConfigurationData = [
                "blockName": event.limit?.name ?? ""
              ]
              sharedDefaultKey = sharedDefaultManager.createTokenKeyString(token: .webDomain(event.webToken), type: .block)
            } else {
              shieldConfigurationData = [
                "limitName": limit?.name ?? "",
                "impulseTime": limit?.impulseTime ?? "",
                "openLimit": limit?.openLimit ?? "",
                "shieldButtonEnable": true,
                "opens": event.opens,
                "eventId": event.id.uuidString
              ]
              
              sharedDefaultKey = sharedDefaultManager.createTokenKeyString(token: .webDomain(event.webToken), type: .limit)
              
              try sharedDefaultManager.writeSharedDefaults(forKey: sharedDefaultKey, data: shieldConfigurationData)
              
              let managedSettingsName = Constants.managedSettingsName(eventId: event.id.uuidString)
              let store = ManagedSettingsStore(named: ManagedSettingsStore.Name(rawValue: managedSettingsName))
              store.shield.webDomains = [event.webToken]
            }
          }
        } catch {
          logger.error("Impulse: error trying to find limit \(error.localizedDescription, privacy: .public)")
        }
        return;
      } else if activity.rawValue.lowercased().contains(Constants.BLOCK_MONITOR_NAME) {
        
        logger.info("Impulse: interval did start for activity \(activity.rawValue, privacy: .public)")

        let blockId = Constants.extractIdForBlock(from: activity.rawValue)
        await getBlock(blockId: blockId)
        let store = ManagedSettingsStore(named: ManagedSettingsStore.Name(rawValue: blockId))
        
        shieldConfigurationData = [
          "blockName": self.block?.name ?? ""
        ]
              
        // Save share defaults for each app
        try block?.appsTokens.forEach{ appToken in
          let sharedDefaultKey = sharedDefaultManager.createTokenKeyString(token: .application(appToken), type: .block)
          try sharedDefaultManager.writeSharedDefaults(forKey: sharedDefaultKey, data: shieldConfigurationData)
          logger.info("Impulse: save shared defaults for app \(sharedDefaultKey, privacy: .public)")
        }

        // Save share defaults for each web domain
        try block?.webDomainTokens.forEach{ webToken in
          let sharedDefaultKey = sharedDefaultManager.createTokenKeyString(token: .webDomain(webToken), type: .block)
          try sharedDefaultManager.writeSharedDefaults(forKey: sharedDefaultKey, data: shieldConfigurationData)
          logger.info("Impulse: save shared default for web \(sharedDefaultKey, privacy: .public)")
        }
        
        if block?.appsTokens.count ?? 0 > 0 {
          store.shield.applications = block?.appsTokens
        }
        
        if block?.webDomainTokens.count ?? 0 > 0 {
          store.shield.webDomains = block?.webDomainTokens
        }

      }
      
    }
  }
  
  override func intervalDidEnd(for activity: DeviceActivityName) {
    super.intervalDidEnd(for: activity)
    Task {
      
      // Validate if activity is for a limit type
      logger.info("Impulse: interval did end for activity \(activity.rawValue, privacy: .public)")
      let sharedDefaultManager = SharedDefaultsManager()
      
      if activity.rawValue.lowercased().contains(Constants.MONITOR_LIMIT_CONTROL_DAY) {
        let activityId = activity.rawValue
        
        await findLimitByActiviyInControlDay(activiyId: activityId)
        
        // Delete shared defaults and reset opens
        try limit?.appsEvents.forEach{appEvent in
          sharedDefaultManager.deleteSharedDefaultsByToken(token: .application(appEvent.appToken), type: .block)
          sharedDefaultManager.deleteSharedDefaultsByToken(token: .application(appEvent.appToken), type: .limit)
          appEvent.opens = 0
          appEvent.status = .warning
          try appEvent.modelContext?.save()
          
          let managedSettingsName = Constants.managedSettingsName(eventId: appEvent.id.uuidString)
          let store = ManagedSettingsStore(named: ManagedSettingsStore.Name(rawValue: managedSettingsName))
          store.clearAllSettings()
        }
        
        try limit?.websEvents.forEach{webEvent in
          sharedDefaultManager.deleteSharedDefaultsByToken(token: .webDomain(webEvent.webToken), type: .block)
          sharedDefaultManager.deleteSharedDefaultsByToken(token: .webDomain(webEvent.webToken), type: .limit)
          webEvent.opens = 0
          webEvent.status = .warning
          try webEvent.modelContext?.save()
          
          let managedSettingsName = Constants.managedSettingsName(eventId: webEvent.id.uuidString)
          let store = ManagedSettingsStore(named: ManagedSettingsStore.Name(rawValue: managedSettingsName))
          store.clearAllSettings()
        }
                
        logger.info("Impulse: apps in limit are unlocked when interval did end")

      } else if activity.rawValue.lowercased().contains(Constants.BLOCK_MONITOR_NAME) {
        
        logger.info("Impulse: interval did end for \(activity.rawValue, privacy: .public)")
        
        let blockId = Constants.extractIdForBlock(from: activity.rawValue)
        let store = ManagedSettingsStore(named: ManagedSettingsStore.Name(rawValue: blockId))
        store.shield.applications = nil
        store.shield.webDomains = nil
        store.clearAllSettings()
        
        block?.appsTokens.forEach{app in
          sharedDefaultManager.deleteSharedDefaultsByToken(token: .application(app), type: .block)
        }
        
        block?.webDomainTokens.forEach{web in
          sharedDefaultManager.deleteSharedDefaultsByToken(token: .webDomain(web), type: .block)
        }
      }
      
    }
  }
  
  func shieldAppAndUpdateEvent(event: AppEvent, isLimitTime: Bool) async {
    do {
      let sharedDefaultManager = SharedDefaultsManager()
      var shieldConfigurationData: [String: Any] = [:]
      let store = ManagedSettingsStore(named: ManagedSettingsStore.Name(rawValue: Constants.managedSettingsName(eventId: event.id.uuidString)))
      var sharedDefaultKey = ""
      
      let openLimit = Int(event.limit?.openLimit ?? "") ?? 0
      let opens = event.opens
      
      logger.info("Impulse: open limit \(event.limit?.openLimit ?? "", privacy: .public)")

      if isLimitTime {
        shieldConfigurationData = [
          "blockName": event.limit?.name ?? ""
        ]
        sharedDefaultKey = sharedDefaultManager.createTokenKeyString(token: .application(event.appToken), type: .block)
        event.status = .block
        try event.modelContext?.save()
      } else if openLimit > 0 && opens >= openLimit {
        logger.info("Impulse: shield app with block configuration, openLimit: \(openLimit, privacy: .public) and opens: \(opens, privacy: .public)")
        shieldConfigurationData = [
          "blockName": event.limit?.name ?? ""
        ]
        sharedDefaultKey = sharedDefaultManager.createTokenKeyString(token: .application(event.appToken), type: .block)
        event.status = .block
        try event.modelContext?.save()
      } else {
        logger.info("Impulse: shield app with limit configuration, openLimit: \(openLimit, privacy: .public) and opens: \(opens, privacy: .public)")
        // Set shield type limit
        shieldConfigurationData = [
          "limitName": event.limit?.name ?? "",
          "impulseTime": event.limit?.impulseTime ?? "",
          "openLimit": event.limit?.openLimit ?? "",
          "shieldButtonEnable": true,
          "opens": event.opens,
          "eventId": event.id.uuidString
        ]
        sharedDefaultKey = sharedDefaultManager.createTokenKeyString(token: .application(event.appToken), type: .limit)
      }
      
      try sharedDefaultManager.writeSharedDefaults(forKey: sharedDefaultKey, data: shieldConfigurationData)
      
      store.shield.applications = [event.appToken]
      
    } catch {
      logger.error("Impulse: error trying to shield app and update event")
    }
  }

  func shieldAppAndUpdateWebEvent(event: WebEvent, isLimitTime: Bool) async {
    do {
      let sharedDefaultManager = SharedDefaultsManager()
      var shieldConfigurationData: [String: Any] = [:]
      let store = ManagedSettingsStore(named: ManagedSettingsStore.Name(rawValue: Constants.managedSettingsName(eventId: event.id.uuidString)))
      var sharedDefaultKey = ""
      
      let openLimit = Int(event.limit?.openLimit ?? "") ?? 0
      let opens = event.opens
      
      logger.info("Impulse: open limit \(event.limit?.openLimit ?? "", privacy: .public)")

      if isLimitTime {
        shieldConfigurationData = [
          "blockName": event.limit?.name ?? ""
        ]
        sharedDefaultKey = sharedDefaultManager.createTokenKeyString(token: .webDomain(event.webToken), type: .block)
        event.status = .block
        try event.modelContext?.save()
      } else if openLimit > 0 && opens >= openLimit {
        logger.info("Impulse: shield web with block configuration, openLimit: \(openLimit, privacy: .public) and opens: \(opens, privacy: .public)")
        shieldConfigurationData = [
          "blockName": event.limit?.name ?? ""
        ]
        sharedDefaultKey = sharedDefaultManager.createTokenKeyString(token: .webDomain(event.webToken), type: .block)
        event.status = .block
        try event.modelContext?.save()
      } else {
        logger.info("Impulse: shield web with limit configuration, openLimit: \(openLimit, privacy: .public) and opens: \(opens, privacy: .public)")
        // Set shield type limit
        shieldConfigurationData = [
          "limitName": event.limit?.name ?? "",
          "impulseTime": event.limit?.impulseTime ?? "",
          "openLimit": event.limit?.openLimit ?? "",
          "shieldButtonEnable": true,
          "opens": event.opens,
          "eventId": event.id.uuidString
        ]
        sharedDefaultKey = sharedDefaultManager.createTokenKeyString(token: .webDomain(event.webToken), type: .limit)
      }
      
      try sharedDefaultManager.writeSharedDefaults(forKey: sharedDefaultKey, data: shieldConfigurationData)
      
      store.shield.webDomains = [event.webToken]
      
    } catch {
      logger.error("Impulse: error trying to shield app and update event")
    }
  }

  override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
    super.eventDidReachThreshold(event, activity: activity)
        
    Task {
      do {
        logger.info("Impulse: event did reach threshold with event id \(event.rawValue, privacy: .public)")
        
        let eventId = self.extractEventId(from: event.rawValue)
        let isLimitTime = self.checkIfIsLimitTime(string: event.rawValue)
        
        logger.info("Impulse: event id \(eventId, privacy: .public)")
                
        // Check identifier
        try await getEvent(eventId: eventId)
        
        if self.typeOfEvent == .app {
          logger.info("Impulse: shield application for event \(self.eventModel?.id.uuidString ?? "no id", privacy: .public)")
          
          if eventModel?.status != .block {
            await shieldAppAndUpdateEvent(event: self.eventModel!, isLimitTime: isLimitTime)
            logger.info("Impulse: shield application")
          } else {
            logger.info("Impulse: app is already blocked")
          }
        } else {
          logger.info("Impulse: shield web for event \(self.webEventModel?.id.uuidString ?? "no id", privacy: .public)")
          
          if webEventModel?.status != .block {
            await shieldAppAndUpdateWebEvent(event: self.webEventModel!, isLimitTime: isLimitTime)
            logger.info("Impulse: shield web")
          } else {
            logger.info("Impulse: web is already blocked")
          }
        }
        
      } catch {
        sharedDefaults?.set("Error during eventDidReachThreshold: \(error.localizedDescription)", forKey: "lastActivityLog")
      }
      
    }
  }
  
  override func intervalWillStartWarning(for activity: DeviceActivityName) {
      super.intervalWillStartWarning(for: activity)
      
      // Handle the warning before the interval starts.
  }
  
  override func intervalWillEndWarning(for activity: DeviceActivityName) {
      super.intervalWillEndWarning(for: activity)
      
      // Handle the warning before the interval ends.
  }
  
  override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
    super.eventWillReachThresholdWarning(event, activity: activity)
  }
}
