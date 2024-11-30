//
//  ShieldConfigurationExtension.swift
//  shieldConfigurator
//
//  Created by Chur Herson on 9/10/24.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit
import Foundation
import SwiftData
import OSLog
import DeviceActivity
import FamilyControls

// Override the functions below to customize the shields used in various situations.
// The system provides a default appearance for any methods that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.

class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    
  private var eventModel: AppEvent?
  private var logger = Logger()
  
  override func configuration(shielding application: Application) -> ShieldConfiguration {
    
    do {
      logger.info("Impulse: start shield configuration")
      let sharedDefaults = UserDefaults(suiteName: "group.com.impulsecontrolapp.impulse.share")
      
      // Conver token to String
      let encoder = JSONEncoder()
      let tokenData = try encoder.encode(application.token)
      let tokenString = String(data: tokenData, encoding: .utf8)
      
      logger.info("Impulse: application token string \(tokenString ?? "", privacy: .public)")
      
      // Validate if shareDefaultData is for block
      if let data = sharedDefaults?.data(forKey:  "\(tokenString ?? "")-block") {
        // If block data exists
        if let shieldConfigurationData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
          let blockName = shieldConfigurationData["blockName"] as? String ?? ""
          
          logger.info("Impulse: shield for block  \(blockName, privacy: .public)")
          return ShieldConfigurationBlock.blockShield(applicationName: application.localizedDisplayName ?? "", eventName: blockName)
        }
      }
            
      if let data = sharedDefaults?.data(forKey: "\(tokenString ?? "")-limit") {
        logger.info("Impulse: find data on share default for limit")
        if let shieldConfigurationData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
          
          logger.info("Impulse: configure shield for limit with data")

          let limitName = shieldConfigurationData["limitName"] as? String ?? ""
          let impulseTime = shieldConfigurationData["impulseTime"] as? Int ?? 0
          let openLimit = shieldConfigurationData["openLimit"] as? String ?? ""
          let shieldButtonEnable = shieldConfigurationData["shieldButtonEnable"] as? Bool ?? true
          let opens = shieldConfigurationData["opens"] as? Int ?? 0
          
          logger.info("Impulse: configure shield with primary button \(shieldButtonEnable)")
          
          // Show limit shield
          return ShieldConfigurationLimit.limitShield(
            applicationName: application.localizedDisplayName ?? "",
            eventName: limitName,
            impulseTime: impulseTime,
            openLimite: openLimit,
            opens: opens,
            shieldButtonEnable: shieldButtonEnable
          )
        }
      }
    } catch {
      logger.error("Impulse: error configuring shield \(error.localizedDescription)")
    }
    
    logger.info("Impulse: render default shield")
    // Default shield
    return ShieldConfiguration()
  }
    
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        // Customize the shield as needed for applications shielded because of their category.
        ShieldConfiguration()
    }
    
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {

      let sharedDefaults = UserDefaults(suiteName: "group.com.impulsecontrolapp.impulse.share")
      
      do {
        // Conver token to String
        let encoder = JSONEncoder()
        let tokenData = try encoder.encode(webDomain.token)
        let tokenString = String(data: tokenData, encoding: .utf8)
        
        logger.info("Impulse: Token string for web domain \(webDomain.domain ?? "", privacy: .public) and token \(tokenString ?? "", privacy: .public)")
        
        // Validate if shareDefaultData is for block
        if let data = sharedDefaults?.data(forKey: "\(tokenString ?? "")-block-web") {
          logger.info("Exist share data for web block")
          // If block data exists
          if let shieldConfigurationData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            let type = shieldConfigurationData["type"] as? String ?? ""
            let blockName = shieldConfigurationData["blockName"] as? String ?? ""
            
            if type == "block" {
              logger.info("Shield for block  \(type, privacy: .public)")
              return ShieldConfigurationBlock.blockShield(applicationName: webDomain.domain ?? "", eventName: blockName)
            }
          }
        }
        
        if let data = sharedDefaults?.data(forKey: tokenString ?? "") {
          if let shieldConfigurationData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            
            logger.info("Shield for impulse mode")

            let limitName = shieldConfigurationData["limitName"] as? String ?? ""
            let enableImpulseMode = shieldConfigurationData["enableImpulseMode"] as? Bool ?? false
            let impulseTime = shieldConfigurationData["impulseTime"] as? Int ?? 0
            let type = shieldConfigurationData["type"] as? String ?? "block"
            let blockIdentifier = shieldConfigurationData["blockIdentifier"] as? String ?? "block"
            let openLimit = shieldConfigurationData["openLimit"] as? String ?? ""
            let shieldButtonEnable = shieldConfigurationData["shieldButtonEnable"] as? Bool ?? true
            
            let isUsageWarning = blockIdentifier == "usage-warning"
            
            if type == "limit" && isUsageWarning {
              // Show limit shield
              return ShieldConfigurationLimit.limitShield(
                applicationName: webDomain.domain ?? "",
                eventName: limitName,
                impulseTime: impulseTime,
                openLimite: openLimit,
                shieldButtonEnable: shieldButtonEnable
              )
            }
            
          }
        }
        
      } catch {
        logger.error("Error making shield \(error.localizedDescription)")
      }
      
      // Default shield
      return ShieldConfiguration()
    }
    
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
      // Customize the shield as needed for web domains shielded because of their category.
      return ShieldConfiguration()
    }
}
