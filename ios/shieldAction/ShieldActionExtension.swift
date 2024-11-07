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


// Override the functions below to customize the shield actions used in various situations.
// The system provides a default response for any functions that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class ShieldActionExtension: ShieldActionDelegate {
  
  private var logger = Logger()
  
    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        // Handle the action as needed.
        switch action {
        case .primaryButtonPressed:
          completionHandler(.close)
        case .secondaryButtonPressed:
          do {
            completionHandler(.defer)
            self.logger.info("Secondary action click")
            let sharedDefaults = UserDefaults(suiteName: "group.com.impulsecontrolapp.impulse.share")
            let encoder = JSONEncoder()
            let tokenData = try encoder.encode(application)
            let tokenString = String(data: tokenData, encoding: .utf8)
            self.logger.info("Token string \(tokenString ?? "null")")
            
            // Find event with app token
            if let data = sharedDefaults?.data(forKey: tokenString ?? "") {
              if let shieldConfigurationData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
               
                let eventId = shieldConfigurationData["eventId"] as? String ?? ""
                let impulseTime = shieldConfigurationData["impulseTime"] as? Int ?? 0
                
                self.logger.info("Event id \(eventId, privacy: .public)")
                self.logger.info("impulse time \(impulseTime, privacy: .public)")
                
                let store = ManagedSettingsStore(named: ManagedSettingsStore.Name(rawValue: "event-\(eventId)"))

                if impulseTime > 0 {
                  DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(impulseTime)) {
                    store.shield.applications = nil
                    self.logger.info("Aplicaciones desbloqueadas después de \(impulseTime) segundos")
                  }
                }else {
                  store.shield.applications = nil
                  self.logger.info("Without impulse time")
                }
              }
            }
          } catch {
            self.logger.error("Error in secondary action \(error.localizedDescription)")
          }
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
