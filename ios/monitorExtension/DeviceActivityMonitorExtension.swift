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
      let result = try context.fetch(fetchDescriptor)
      eventModel = result.first
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
  
  func extractEventId(from eventRawValue: String) -> (value: String, identifier: String?) {
    let eventIdentifier = "-limit-time"
    let impulseWarningIdentifier = "-usage-warning"
    
    // Verifica si el string contiene el identificador
    if let range = eventRawValue.range(of: eventIdentifier) {
      // Si se encuentra, extrae la parte anterior
      return (String(eventRawValue[..<range.lowerBound]), "limit-time")
    } else if let impulseWarningRange = eventRawValue.range(of: impulseWarningIdentifier) {
      return (String(eventRawValue[..<impulseWarningRange.lowerBound]), "usage-warning")
    }
    
    // Si no se encuentra, devolver el string original
    return (eventRawValue, nil)
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
      
      // Validate if activity is for limit
      if activity.rawValue.lowercased().contains("limit") {
        logger.info("Impulse: interval did start, find limit info")
        let limitId = extractLimitId(from: activity.rawValue)
        logger.info("Impulse: limit id \(limitId, privacy: .public)")
        do {
          logger.info("Impulse: block apps when interval did start")
          try await getLimit(limitId: limitId)
          let store = ManagedSettingsStore(named: ManagedSettingsStore.Name(rawValue: "limit-start-block"))
          store.shield.applications = limit?.appsTokens
        } catch {
          logger.error("Impulse: error trying to find limit")
        }
        
        return;
      }
      
      logger.info("Impulse: interval did start for activity \(activity.rawValue, privacy: .public)")

      let activityId = Constants.extractIdForBlock(from: activity.rawValue)
      await getBlock(blockId: activityId)
      let store = ManagedSettingsStore(named: ManagedSettingsStore.Name(rawValue: activityId))
      
      let shieldConfigurationData = [
        "type": "block",
        "blockName": block?.name
      ]
      
      let sharedDefaultManager = SharedDefaultsManager()
      
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
      
      store.shield.applications = block?.appsTokens
      store.shield.webDomains = block?.webDomainTokens
    }
  }
  
  override func intervalDidEnd(for activity: DeviceActivityName) {
    super.intervalDidEnd(for: activity)
    Task {
      
      // Validate if activity is for a limit type
      logger.info("Impulse: interval did end for activity \(activity.rawValue, privacy: .public)")
      
      if activity.rawValue.lowercased().contains("limit") {
        let activityId = activity.rawValue

        let activityLimitIdentifier = getLimitIdentifier(activiyId: activityId)
                        
        await findLimitByActiviyId(activiyId: activityId)
        let limitId = self.limit?.id.uuidString
        
        let managedStoreName = "\(limitId ?? "")\(activityLimitIdentifier ?? "")"
        
        logger.info("Impulse: managed stored name \(managedStoreName)")
        
        let store = ManagedSettingsStore(named: ManagedSettingsStore.Name(rawValue: managedStoreName))
        store.shield.applications = nil
        
        let events = self.limit?.appsEvents
        events?.forEach{event in
          let eventStoreName = "event-\(event.id.uuidString)"
          let eventStore = ManagedSettingsStore(named: ManagedSettingsStore.Name(rawValue: eventStoreName))
          eventStore.shield.applications = nil
          logger.info("Impulse: remove shield for event \(eventStoreName)")
        }
        
        logger.info("Impulse: apps in limit are unlocked when interval did end")
        return;
      }
      
      // When block end
      let activityId = Constants.extractIdForBlock(from: activity.rawValue)
      let store = ManagedSettingsStore(named: ManagedSettingsStore.Name(rawValue: activityId))
      store.shield.applications = nil
      store.shield.webDomains = nil
      store.clearAllSettings()
      
      await getBlock(blockId: activityId)
      block?.appsTokens.forEach{appToken in
        do {
          let tokenData = try JSONEncoder().encode(appToken.self)
          let tokenString = String(data: tokenData, encoding: .utf8)
          sharedDefaults?.removeObject(forKey: "\(tokenString ?? "")-block")
        } catch {
          logger.error("Impulse: error trying to remove shared default for app")
        }
      }
      
      block?.webDomainTokens.forEach{webToken in
        do {
          let tokenData = try JSONEncoder().encode(webToken.self)
          let tokenString = String(data: tokenData, encoding: .utf8)
          sharedDefaults?.removeObject(forKey: "\(tokenString ?? "")-block-web")
        } catch {
          logger.error("Impulse: error trying to remove shared default for web")
        }
      }
      
    }
  }
    
  override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
    super.eventDidReachThreshold(event, activity: activity)
    
    logger.info("Impulse: event did reach threshold \(event.rawValue, privacy: .public) \(activity.rawValue, privacy: .public)")
    
    Task {
      do {
        logger.info("Impulse: event did reach threshold with event id \(event.rawValue, privacy: .public)")
        
        let result = self.extractEventId(from: event.rawValue)
        let eventId = result.value
        let identifier = result.identifier
                
        // Check identifier
        try await getEvent(eventId: eventId)
        
        let store = ManagedSettingsStore(named: ManagedSettingsStore.Name(rawValue: "event-\(eventId)"))
        
        if let appToken = eventModel?.appToken {
          
          let encoder = JSONEncoder()
          let tokenData = try encoder.encode(appToken)
          
          // Validate type of shield
          if identifier == "usage-warning" {
            logger.info("Impulse: Configure share data for usage warning")
            
            let newOpenLimit = Int((self.eventModel?.limit!.openLimit)!)! - 1
            
            if self.eventModel?.opens ?? 0 == newOpenLimit{
              logger.info("Impulse: block app because opens is equal to open limit")
              let shieldConfigurationData = [
                "blockName": self.eventModel?.limit?.name ?? ""
              ]
              let shareData = try JSONSerialization.data(withJSONObject: shieldConfigurationData, options: [])
              if let tokenString = String(data: tokenData, encoding: .utf8) {
                let sharedDefaultKey = "\(tokenString)-block"
                logger.info("Impulse: block key for shared data \(sharedDefaultKey, privacy: .public)-block")
                sharedDefaults?.set(shareData, forKey: sharedDefaultKey)
                sharedDefaults?.removeObject(forKey: "\(tokenString)-limit")
              }
              store.shield.applications = Set([appToken])
              await saveLimitHistory()
              return
            }
            
            // Save shield data
            let shieldConfigurationData = [
              "limitName": self.eventModel?.limit?.name ?? "",
              "impulseTime": self.eventModel?.limit?.impulseTime ?? 0,
              "openLimit": self.eventModel?.limit?.openLimit ?? "",
              "usageWarning": self.eventModel?.limit?.usageWarning ?? 0,
              "eventId": eventId,
              "shieldButtonEnable": true,
              "opens": self.eventModel?.opens ?? 0
            ]
            
            let data = try JSONSerialization.data(withJSONObject: shieldConfigurationData, options: [])
            
            if let tokenString = String(data: tokenData, encoding: .utf8) {
              let sharedDefaultKey = "\(tokenString)-limit"
              sharedDefaults?.set(data, forKey: sharedDefaultKey)
              sharedDefaults?.removeObject(forKey: "\(tokenString)-block")
            }
            
            // Add one to event counter
            // eventModel?.opens += 1
            // try eventModel?.modelContext?.save()
            
          } else {
            logger.info("Impulse: Configure share data for limit block")
            let shieldConfigurationData = [
              "blockName": self.eventModel?.limit?.name ?? ""
            ]
            let shareData = try JSONSerialization.data(withJSONObject: shieldConfigurationData, options: [])
            if let tokenString = String(data: tokenData, encoding: .utf8) {
              let sharedDefaultKey = "\(tokenString)-block"
              logger.info("Impulse: block key for shared data \(sharedDefaultKey, privacy: .public)-block")
              sharedDefaults?.set(shareData, forKey: sharedDefaultKey)
              sharedDefaults?.removeObject(forKey: "\(tokenString)-limit")
            }
          }
          
          // Shield app and save history
          store.shield.applications = Set([appToken])
          await saveLimitHistory()
          
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
      
      // Handle the warning before the event reaches its threshold.
  }
}
