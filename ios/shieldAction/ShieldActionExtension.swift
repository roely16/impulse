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
            // Convert token to String
            let encoder = JSONEncoder()
            let tokenData = try encoder.encode(application)
            let tokenString = String(data: tokenData, encoding: .utf8)
            
            logger.info("Token string \(tokenString ?? "", privacy: .public)")
            
            let sharedDefaults = UserDefaults(suiteName: "group.com.impulsecontrolapp.impulse.share")
            
            // Check if is block
            // Validate if shareDefaultData is for block
            if let data = sharedDefaults?.data(forKey:  "\(tokenString ?? "")-block") {
              // If block data exists
              if let shieldConfigurationData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                let type = shieldConfigurationData["type"] as? String ?? ""
                
                if type == "block" {
                  completionHandler(.close)
                  return
                }
              }
            }
                        
            // Find event with app token
            if let data = sharedDefaults?.data(forKey: tokenString ?? "") {
              if var shieldConfigurationData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                
                // Update shield with disable style button
                shieldConfigurationData["shieldButtonEnable"] = false
                let data = try JSONSerialization.data(withJSONObject: shieldConfigurationData, options: [])
                if let tokenString = String(data: tokenData, encoding: .utf8) {
                  sharedDefaults?.set(data, forKey: tokenString)
                }
                
                completionHandler(.defer)

                let eventId = shieldConfigurationData["eventId"] as? String ?? ""
                let impulseTime = shieldConfigurationData["impulseTime"] as? Int ?? 0
                let usageWarning = shieldConfigurationData["usageWarning"] as? Int ?? 0
                
                // let isImpulseWarning = blockIdentifier == "usage-warning"
                
                self.logger.info("Event id \(eventId, privacy: .public)")
                self.logger.info("impulse time \(impulseTime, privacy: .public)")
                
                let store = ManagedSettingsStore(named: ManagedSettingsStore.Name(rawValue: "event-\(eventId)"))

                if impulseTime > 0 {
                  DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(impulseTime)) {
                    store.shield.applications = nil
                    self.logger.info("Aplicaciones desbloqueadas después de \(impulseTime) segundos")
                    sharedDefaults?.removeObject(forKey: tokenString ?? "")
                  }
                  
                  // Create again the usage warning
                  var eventsArray: [DeviceActivityEvent.Name: DeviceActivityEvent] = [:]
                  
                  let threshold = DateComponents(minute: usageWarning)
                  let eventName = DeviceActivityEvent.Name(rawValue: "\(eventId)-usage-warning")
                  let activityEvent = DeviceActivityEvent(applications: [application], threshold: threshold)
                  
                  eventsArray[eventName] = activityEvent
                  
                  let deviceActivityCenter = DeviceActivityCenter();
                  
                  try deviceActivityCenter.startMonitoring(
                    DeviceActivityName(rawValue: "\(eventId)-limit"),
                    during: DeviceActivitySchedule(
                      intervalStart: DateComponents(hour: 0, minute: 0),
                      intervalEnd: DateComponents(hour: 23, minute: 59),
                      repeats: false
                    ),
                    events: eventsArray
                  )
                  
                }else {
                  store.shield.applications = nil
                  self.logger.info("Without impulse time")
                }
              }
            }
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
