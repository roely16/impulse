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
  private var sharedDefaultsManager = SharedDefaultsManager()
  
  override func configuration(shielding application: Application) -> ShieldConfiguration {
    
    do {
      logger.info("Impulse: start shield configuration for app")

      if let appToken = application.token {
        
        // Validate if exists a configuration for a block
        if let shieldConfigurationData = try sharedDefaultsManager.readSharedDefaultsByToken(token: .application(appToken), type: .block) {
          
          logger.info("Impulse: find shield configuration for block")
          
          let blockName = shieldConfigurationData["blockName"] as? String ?? ""
          
          return ShieldConfigurationBlock.blockShield(applicationName: application.localizedDisplayName ?? "", eventName: blockName)
        }
        
        // Validate if exists a configuration for a limit
        if let shieldConfigurationData = try sharedDefaultsManager.readSharedDefaultsByToken(token: .application(appToken), type: .limit) {
          
          logger.info("Impulse: find shield configuration for limit")

          let limitName = shieldConfigurationData["limitName"] as? String ?? ""
          let impulseTime = shieldConfigurationData["impulseTime"] as? Int ?? 0
          let openLimit = shieldConfigurationData["openLimit"] as? String ?? ""
          let shieldButtonEnable = shieldConfigurationData["shieldButtonEnable"] as? Bool ?? true
          let opens = shieldConfigurationData["opens"] as? Int ?? 0
          
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
    return ShieldConfiguration()
  }
    
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        // Customize the shield as needed for applications shielded because of their category.
        ShieldConfiguration()
    }
    
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
      do {
        logger.info("Impulse: start shield configuration for app")

        if let webToken = webDomain.token {
          
          // Validate if exists a configuration for a block
          if let shieldConfigurationData = try sharedDefaultsManager.readSharedDefaultsByToken(token: .webDomain(webToken), type: .block) {
            
            logger.info("Impulse: find shield configuration for block")
            
            let blockName = shieldConfigurationData["blockName"] as? String ?? ""
            
            return ShieldConfigurationBlock.blockShield(applicationName: webDomain.domain ?? "", eventName: blockName)
          }
          
          // Validate if exists a configuration for a limit
          if let shieldConfigurationData = try sharedDefaultsManager.readSharedDefaultsByToken(token: .webDomain(webToken), type: .limit) {
            
            logger.info("Impulse: find shield configuration for limit")

            let limitName = shieldConfigurationData["limitName"] as? String ?? ""
            let impulseTime = shieldConfigurationData["impulseTime"] as? Int ?? 0
            let openLimit = shieldConfigurationData["openLimit"] as? String ?? ""
            let shieldButtonEnable = shieldConfigurationData["shieldButtonEnable"] as? Bool ?? true
            let opens = shieldConfigurationData["opens"] as? Int ?? 0
            
            return ShieldConfigurationLimit.limitShield(
              applicationName: webDomain.domain ?? "",
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
      return ShieldConfiguration()
    }
    
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
      // Customize the shield as needed for web domains shielded because of their category.
      return ShieldConfiguration()
    }
}
