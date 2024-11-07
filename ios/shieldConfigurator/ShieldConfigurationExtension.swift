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
  
  func limitShield(application: Application, eventName: String = "", enableImpulseMode: Bool = false, impulseTime: Int = 0) -> ShieldConfiguration{
    
    let secondaryButtonText = enableImpulseMode ? "Continuar en \(impulseTime) seg" : "Continuar"
    
    return ShieldConfiguration(
      backgroundBlurStyle: UIBlurEffect.Style.light,
      backgroundColor: UIColor(hex: "#FDE047"),
      icon: UIImage(named: "impulse-icon"),
      title: ShieldConfiguration.Label(text: "\n\n¿Quieres\ncontinuar?", color: UIColor.black),
      subtitle: ShieldConfiguration.Label(text: "Intentos de apertura: 70", color: UIColor.black),
      primaryButtonLabel: ShieldConfiguration.Label(text: "Cerrar App", color: UIColor.black),
      primaryButtonBackgroundColor: UIColor.white,
      secondaryButtonLabel: ShieldConfiguration.Label(text: secondaryButtonText, color: UIColor.black)
    )
    
  }
  
  func blockShield(application: Application, eventName: String = "") -> ShieldConfiguration{
    return ShieldConfiguration(
      backgroundBlurStyle: UIBlurEffect.Style.light,
      backgroundColor: UIColor(hex: "#FDE047"),
      icon: UIImage(named: "lock-shield-icon"),
      title: ShieldConfiguration.Label(text: "\(application.localizedDisplayName ?? "App") esta\nbloqueada", color: UIColor.black),
      subtitle: ShieldConfiguration.Label(text: "Tienes configurado bloquear \(application.localizedDisplayName ?? "app") durante \(eventName)", color: UIColor.black),
      primaryButtonLabel: ShieldConfiguration.Label(text: "Cerrar", color: UIColor.black),
      primaryButtonBackgroundColor: UIColor.white
    )
  }
  
  override func configuration(shielding application: Application) -> ShieldConfiguration {
    
    do {
      let sharedDefaults = UserDefaults(suiteName: "group.com.impulsecontrolapp.impulse.share")
      let encoder = JSONEncoder()
      let tokenData = try encoder.encode(application.token)
      let tokenString = String(data: tokenData, encoding: .utf8)
      if let data = sharedDefaults?.data(forKey: tokenString ?? "") {
        if let shieldConfigurationData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
          
          let limitName = shieldConfigurationData["limitName"] as? String ?? ""
          let enableImpulseMode = shieldConfigurationData["enableImpulseMode"] as? Bool ?? false
          let impulseTime = shieldConfigurationData["impulseTime"] as? Int ?? 0
          let type = shieldConfigurationData["type"] as? String ?? "block"
                    
          if type == "limit" {
            // Show limit shield
            return limitShield(application: application, eventName: limitName, enableImpulseMode: enableImpulseMode, impulseTime: impulseTime)
          }
          
          // Show block shield
          return blockShield(application: application, eventName: limitName);
        }
      }
    } catch {
      logger.error("Error making shield \(error.localizedDescription)")
    }
    
    logger.info("Default shield")
    // Default shield
    return ShieldConfiguration()
  }
    
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        // Customize the shield as needed for applications shielded because of their category.
        ShieldConfiguration()
    }
    
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        // Customize the shield as needed for web domains.
        return ShieldConfiguration()
    }
    
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        // Customize the shield as needed for web domains shielded because of their category.
        ShieldConfiguration()
    }
}
