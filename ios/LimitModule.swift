import Foundation
import SwiftData
import DeviceActivity
import ManagedSettings
import React

@objc(LimitModule)
class LimitModule: NSObject {
  private var container: ModelContainer?
  private var logger = Logger()
  static let shared = LimitModule()
  
  private override init() {
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
  
  @MainActor
  func findLimits() -> [Limit]{
    do {
      let context = try getContext()
      
      let fetchDescriptor = FetchDescriptor<Limit>()
      let limits = try context.fetch(fetchDescriptor)
      
      return limits
    
    } catch {
      print("Error trying to get limits")
      return []
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
  
  @MainActor
  func disableLimit(limitId: UUID, updateStore: Bool = false){
    do {
      // Remove shields
      let limit = findLimit(limitId: limitId)
      limit?.appsEvents.forEach{event in
        let store = ManagedSettingsStore(named: ManagedSettingsStore.Name(rawValue: "event-\(event.id.uuidString)"))
        store.shield.applications = nil
      }
      
      // Stop monitoring
      let deviceActivityCenter = DeviceActivityCenter();

      // Validate if weekdays is upper 0
      if limit?.weekdays.count ?? 0 > 0 {
        // Remove for each day
        limit?.weekdays.forEach { weekday in
          let deviceActivityCenter = DeviceActivityCenter();
          deviceActivityCenter.stopMonitoring([DeviceActivityName(rawValue: "\(limitId.uuidString)-limit-day-\(weekday)")])
        }
      } else {
        deviceActivityCenter.stopMonitoring([DeviceActivityName(rawValue: "\(String(describing: limitId.uuidString))-limit")])
      }
      
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
      limit?.appsEvents.forEach{event in
        if minutesToBlock != nil {
          let threshold = DateComponents(minute: minutesToBlock)
          let eventName = DeviceActivityEvent.Name(rawValue: "\(event.id.uuidString)-event")
          let activityEvent = DeviceActivityEvent(applications: [event.appToken], threshold: threshold)
                    
          eventsArray[eventName] = activityEvent
          
          // Find if the event has history
          let numberOfEvents = findLimitHistory(event: event)

          if numberOfEvents! > 0 {
            // Block app if the event has history
            let store = ManagedSettingsStore(named: ManagedSettingsStore.Name(rawValue: "event-\(event.id.uuidString)"))
            store.shield.applications = [event.appToken]
          }
          
        }
      }
      
      // Start monitoring
      let deviceActivityCenter = DeviceActivityCenter();
      
      let activities = deviceActivityCenter.activities
      
      print("current activities \(activities)")
      
      let weekdays: [Int] = limit?.weekdays ?? []
      
      // Validate if weekdays is upper 0
      if weekdays.count > 0 {
        logger.info("Enable frecuency")
        try weekdays.forEach { weekday in
          logger.info("Create monitoring with weekday: \(weekday)")
          try deviceActivityCenter.startMonitoring(
            DeviceActivityName(rawValue: "\(limit?.id.uuidString ?? "")-limit-day-\(weekday)"),
            during: DeviceActivitySchedule(
              intervalStart: DateComponents(hour: 0, minute: 0, weekday: weekday),
              intervalEnd: DateComponents(hour: 23, minute: 59, weekday: weekday),
              repeats: true
            ),
            events: eventsArray
          )
        }
      } else {
        try deviceActivityCenter.startMonitoring(
          DeviceActivityName(rawValue: "\(limitId.uuidString)-limit"),
          during: DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: false
          ),
          events: eventsArray
        )
      }

      // Update limit status
      if updateStore {
        limit?.enable = true
        try limit?.modelContext?.save()
      }
    } catch {
      print("Error trying to enable limit")
    }
  }
  
  func getLimitTime(time: String = "") -> Int {
    let components = time.split(separator: ":")
    if let hours = Int(components[0]), let minutes = Int(components[1]) {
      let totalMinutes = (hours * 60) + minutes
      return totalMinutes
    } else {
      logger.info("Impulse: time wrong format \(time, privacy: .public)")
      return 0
    }
  }
  
  @MainActor
  func findLimitHistory(event: AppEvent) -> Int? {
    do {
      
      let calendar = Calendar.current
      let startOfDay = calendar.startOfDay(for: Date())
      let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
      
      let history = try event.history.filter(#Predicate{ $0.date >= startOfDay && $0.date < endOfDay })
      
      return history.count
    } catch {
      print("Error trying to get limit history")
      return nil
    }
  }
  
  /* CRUD FUNCTIONS */
  
  @MainActor @objc
  func getLimits(
    _ resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ){
    let limits = findLimits()
    
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
  }
  
  @MainActor @objc
  func getLimitDetail(
    _ limitId: String,
    resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ){
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
      "weekdays": limit?.weekdays,
      "impulseTime": limit?.impulseTime,
      "usageWarning": limit?.usageWarning
    ] as [String : Any]
    
    resolve(["status": "success", "limit" : limitData])
  }
  
  @MainActor @objc
  func deleteLimit(
    _ limitId: String = "",
    resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ){
    do {
      guard let uuid = UUID(uuidString: limitId) else {
        reject("invalid_uuid", "The limit id is not a valid UUID", nil)
        return
      }
      
      // Get events
      let limit = findLimit(limitId: uuid)
      let context = try getContext()
      
      limit?.appsEvents.forEach{event in
        // Remove restrictions for every app
        let store = ManagedSettingsStore(named: ManagedSettingsStore.Name(rawValue: "event-\(event.id.uuidString)"))
        store.shield.applications = nil
        
        // Remove usage warning
        let eventId = event.id.uuidString
        // deviceActivityCenter.stopMonitoring([DeviceActivityName(rawValue: "\(eventId)-usage-warning")])
        
      }
      
      // Stop monitoring
      let deviceActivityCenter = DeviceActivityCenter();

      // Validate if weekdays is upper 0
      if (limit?.weekdays.count)! > 0 {
        // Remove for each day
        limit?.weekdays.forEach { weekday in
          deviceActivityCenter.stopMonitoring([DeviceActivityName(rawValue: "\(uuid)-limit-day-\(weekday)")])
        }
      } else {
        deviceActivityCenter.stopMonitoring([DeviceActivityName(rawValue: "\(uuid)-limit")])
      }
            
      // Delete limit and events
      try context.delete(model: Limit.self, where: #Predicate { $0.id == uuid })
      resolve(["status": "success"])
    } catch {
      print("Error trying to delete limit")
    }
  }
  
  @MainActor @objc
  func updateLimitStatus(
    _ limitId: String = "",
    enable: Bool,
    resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
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
  
}
