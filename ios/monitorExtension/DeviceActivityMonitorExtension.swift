//
//  DeviceActivityMonitorExtension.swift
//  monitorExtension
//
//  Created by Chur Herson on 11/10/24.
//

import DeviceActivity
import os.log
import UserNotifications
import SwiftData
import ManagedSettings
import Foundation

let sharedDefaults = UserDefaults(suiteName: "group.com.impulsecontrolapp.impulse.share")

// Optionally override any of the functions below.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class DeviceActivityMonitorExtension: DeviceActivityMonitor {
  
  private var block: Block?
  private var limit: Limit?
  private var eventModel: Event?
  
  private lazy var container: ModelContainer = {
    let configuration = ModelConfiguration(
        isStoredInMemoryOnly: false,
        allowsSave: true,
        groupContainer: .identifier("group.com.impulsecontrolapp.impulse.share")
    )
    return try! ModelContainer(for: Block.self, Limit.self, Event.self, LimitHistory.self, configurations: configuration)
  }()
  
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
      let fetchDescriptor = FetchDescriptor<Event>(
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
      let history = LimitHistory(
        event: eventModel!
      )
      context.insert(history)
      try context.save()
    } catch {
      print("Error trying to save limit history")
    }
  }
  
  func extractId(from activityRawValue: String) -> String {
      let dayIdentifier = "-day-"

      // Verifica si el string contiene el identificador
      if let range = activityRawValue.range(of: dayIdentifier) {
          // Si se encuentra, extrae la parte anterior
          return String(activityRawValue[..<range.lowerBound])
      }
      
      // Si no se encuentra, devolver el string original
      return activityRawValue
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
  
  func extractEventId(from eventRawValue: String) -> String {
      let eventIdentifier = "-event"

      // Verifica si el string contiene el identificador
      if let range = eventRawValue.range(of: eventIdentifier) {
          // Si se encuentra, extrae la parte anterior
          return String(eventRawValue[..<range.lowerBound])
      }
      
      // Si no se encuentra, devolver el string original
      return eventRawValue
  }
  
  override func intervalDidStart(for activity: DeviceActivityName) {
    super.intervalDidStart(for: activity)
    Task {
      let activityId = extractId(from: activity.rawValue)
      await getBlock(blockId: activityId)
      let store = ManagedSettingsStore(named: ManagedSettingsStore.Name(rawValue: activityId))
      store.shield.applications = block?.appsTokens
      sharedDefaults?.set("Activity started: \(activityId) \(activity.rawValue)", forKey: "lastActivityLog")
    }
  }
  
  override func intervalDidEnd(for activity: DeviceActivityName) {
    super.intervalDidEnd(for: activity)
    Task {
      let activityId = extractId(from: activity.rawValue)
      let store = ManagedSettingsStore(named: ManagedSettingsStore.Name(rawValue: activityId))
      store.shield.applications = nil
    }
  }
    
  override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
    super.eventDidReachThreshold(event, activity: activity)
    
    Task {
      do {
        
        let eventId = extractEventId(from: event.rawValue)
        try await getEvent(eventId: eventId)
        
        let store = ManagedSettingsStore(named: ManagedSettingsStore.Name(rawValue: "event-\(eventId)"))
        
        if let appToken = eventModel?.appToken {
          store.shield.applications = Set([appToken])
          await saveLimitHistory()
          let encoder = JSONEncoder()
          let tokenData = try encoder.encode(appToken)
          
          let shieldConfigurationData = [
            "limitName": eventModel?.limit?.name ?? "",
            "enableImpulseMode": eventModel?.limit?.enableImpulseMode ?? false,
            "impulseTime": eventModel?.limit?.impulseTime ?? 0,
            "type": "limit",
            "eventId": eventId
          ]
          
          let data = try JSONSerialization.data(withJSONObject: shieldConfigurationData, options: [])
          
          if let tokenString = String(data: tokenData, encoding: .utf8) {
            sharedDefaults?.set(data, forKey: tokenString)
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
      
      // Handle the warning before the event reaches its threshold.
  }
}
