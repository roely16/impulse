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

let sharedDefaults = UserDefaults(suiteName: "group.com.impulsecontrolapp.impulse.share")

// Optionally override any of the functions below.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class DeviceActivityMonitorExtension: DeviceActivityMonitor {
  
  private var block: Block?
  
  @MainActor func getBlock(blockId: String){
    do {
      guard let uuid = UUID(uuidString: blockId) else {
        return
      }
      let configuration = ModelConfiguration(isStoredInMemoryOnly: false, allowsSave: true, groupContainer: ( .identifier("group.com.impulsecontrolapp.impulse.share") ))
      let container = try ModelContainer(
        for: Block.self,
        configurations: configuration
      )
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
      
      // Handle the event reaching its threshold.
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
