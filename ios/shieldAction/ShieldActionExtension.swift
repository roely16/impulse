//
//  ShieldActionExtension.swift
//  shieldAction
//
//  Created by Chur Herson on 9/10/24.
//

import ManagedSettings
import Foundation
import OSLog
import ManagedSettings
import FamilyControls
import DeviceActivity


// Override the functions below to customize the shield actions used in various situations.
// The system provides a default response for any functions that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class ShieldActionExtension: ShieldActionDelegate {
  
  private var logger = Logger()
  
    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        // Handle the action as needed.
        switch action {
        case .primaryButtonPressed:
          do {
            logger.info("Impulse: pulse primary button")
            // Convert token to String
            let encoder = JSONEncoder()
            let tokenData = try encoder.encode(application)
            let tokenString = String(data: tokenData, encoding: .utf8)
                        
            let sharedDefaults = UserDefaults(suiteName: "group.com.impulsecontrolapp.impulse.share")
            
            // Check if is block
            // Validate if shareDefaultData is for block
            if (sharedDefaults?.data(forKey:  "\(tokenString ?? "")-block")) != nil {
              logger.info("Impulse: resolve action for block")
              completionHandler(.close)
              return
            }
                        
            // Find data for limit
            if let data = sharedDefaults?.data(forKey: "\(tokenString ?? "")-limit") {
              if var shieldConfigurationData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                logger.info("Impulse: resolve action for limit")
                
                // Update shield with disable style button
                shieldConfigurationData["shieldButtonEnable"] = false
                shieldConfigurationData["opens"] = shieldConfigurationData["opens"] as! Int + 1
                let data = try JSONSerialization.data(withJSONObject: shieldConfigurationData, options: [])
                if let tokenString = String(data: tokenData, encoding: .utf8) {
                  let sharedDefaultKey = "\(tokenString)-limit"
                  sharedDefaults?.set(data, forKey: sharedDefaultKey)
                }
                
                completionHandler(.defer)
                
                let eventId = shieldConfigurationData["eventId"] as? String ?? ""
                let impulseTime = shieldConfigurationData["impulseTime"] as? Int ?? 0
                let startBlocking = shieldConfigurationData["startBlocking"] as? Bool ?? false
                let usageWarning = shieldConfigurationData["usageWarning"] as? Int ?? 0
                
                self.logger.info("Impulse: Event id \(eventId, privacy: .public)")
                self.logger.info("Impulse: impulse time \(impulseTime, privacy: .public)")
                
                let storeName = startBlocking ? "limit-start-block" : "event-\(eventId)"
                
                // TO-DO
                // Add 1 open to event if is limit-start-block
                
                let store = ManagedSettingsStore(named: ManagedSettingsStore.Name(rawValue: storeName))
                
                if impulseTime > 0 {
                  DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(impulseTime)) {
                    store.shield.applications = nil
                    self.logger.info("Impulse: Aplicaciones desbloqueadas después de \(impulseTime) segundos")
                    completionHandler(.close)
                  }
                  
                } else {
                  store.shield.applications = nil
                  self.logger.info("Without impulse time")
                }
                
                // Create again the usage warning
                
                var eventsArray: [DeviceActivityEvent.Name: DeviceActivityEvent] = [:]
                
                let threshold = DateComponents(minute: usageWarning)
                let eventName = DeviceActivityEvent.Name(rawValue: "\(eventId)-usage-warning")
                let activityEvent = DeviceActivityEvent(applications: [application], threshold: threshold)
                
                eventsArray[eventName] = activityEvent
                
                let deviceActivityCenter = DeviceActivityCenter();
                
                try deviceActivityCenter.startMonitoring(
                  DeviceActivityName(rawValue: "\(eventId)-usage-warning"),
                  during: DeviceActivitySchedule(
                    intervalStart: DateComponents(hour: 0, minute: 0),
                    intervalEnd: DateComponents(hour: 23, minute: 59),
                    repeats: false
                  ),
                  events: eventsArray
                )
                
              }
              return
            }
            logger.info("Impulse: shield action without block or limit")
            completionHandler(.close)
          } catch {
            self.logger.error("Error in secondary action \(error.localizedDescription)")
          }
        case .secondaryButtonPressed:
          completionHandler(.close)
        @unknown default:
            fatalError()
        }
    }
    
    override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        // Handle the action as needed.
        completionHandler(.close)
    }
    
    override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        // Handle the action as needed.
        completionHandler(.close)
    }
}
