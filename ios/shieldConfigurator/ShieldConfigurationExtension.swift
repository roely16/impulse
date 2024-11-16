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

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted.remove(at: hexFormatted.startIndex)
        }
        
        assert(hexFormatted.count == 6, "Hex color string must be 6 characters long")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}

// Override the functions below to customize the shields used in various situations.
// The system provides a default appearance for any methods that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.

class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    
  private var eventModel: Event?
  private var logger = Logger()
  
  func limitShield(
    applicationName: String = "",
    eventName: String = "",
    impulseTime: Int = 0,
    openLimite: String = "",
    opens: Int = 0,
    shieldButtonEnable: Bool = true
  ) -> ShieldConfiguration{
    
    let secondaryButtonText = "Continuar en \(impulseTime) seg"
    
    let disableButtonColorBack = UIColor(hex: "#e6e6e6")
    let disableButtonColotText = UIColor.black
    
    let enableButtonColorBack = UIColor.black
    let enableButtonColorText = UIColor(hex: "#FDE047")
    
    let buttonBackground = shieldButtonEnable ? enableButtonColorBack : disableButtonColorBack
    let buttonTextColor = shieldButtonEnable ? enableButtonColorText : disableButtonColotText
    
    let numberOfOpenLimite = Int(openLimite)
  
    let openLimiteText = numberOfOpenLimite ?? 0 > 0 ? "\(opens)/\(numberOfOpenLimite ?? 0)" : "\(opens)"
    let subtitle = "Tienes configurado bloquear \(applicationName) durante \(eventName) \n\n\n Intentos de apertura: \(openLimiteText)"
    
    return ShieldConfiguration(
      backgroundBlurStyle: UIBlurEffect.Style.light,
      backgroundColor: UIColor(hex: "#FDE047"),
      icon: UIImage(named: "impulse-icon"),
      title: ShieldConfiguration.Label(text: "\n\n¿Quieres\ncontinuar?", color: UIColor.black),
      subtitle: ShieldConfiguration.Label(text: subtitle, color: UIColor.black),
      primaryButtonLabel: ShieldConfiguration.Label(text: secondaryButtonText, color: enableButtonColorText),
      primaryButtonBackgroundColor: enableButtonColorBack,
      secondaryButtonLabel: ShieldConfiguration.Label(text: "Cerrar App", color: UIColor.black)
    )
    
  }
  
  func blockShield(applicationName: String = "", eventName: String = "") -> ShieldConfiguration{
    return ShieldConfiguration(
      backgroundBlurStyle: UIBlurEffect.Style.light,
      backgroundColor: UIColor(hex: "#FDE047"),
      icon: UIImage(named: "lock-shield-icon"),
      title: ShieldConfiguration.Label(text: "\(applicationName) esta\nbloqueada", color: UIColor.black),
      subtitle: ShieldConfiguration.Label(text: "Tienes configurado bloquear \(applicationName) durante \(eventName)", color: UIColor.black),
      primaryButtonLabel: ShieldConfiguration.Label(text: "Cerrar", color: UIColor.black),
      primaryButtonBackgroundColor: UIColor.white
    )
  }
  
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
          return blockShield(applicationName: application.localizedDisplayName ?? "", eventName: blockName)
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
          return limitShield(
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
      
      let blockedWebs = sharedDefaults?.array(forKey: "webs-blocked") as? [String] ?? [String]()
      blockedWebs.forEach { web in
        if let tokenData = web.data(using: .utf8) {
          do {
            let token = try JSONDecoder().decode(WebDomainToken.self, from: tokenData)
            let newDomain = WebDomain(token: token)
            logger.info("Domain \(newDomain.domain ?? "Empty domain", privacy: .public)")
            
            // Validate tokens
            if token == webDomain.token {
              logger.info("Match token")
            }
          } catch {
            logger.info("Error trying to get domain")
          }
        }
      }
      
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
              return blockShield(applicationName: webDomain.domain ?? "", eventName: blockName)
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
              return limitShield(
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
