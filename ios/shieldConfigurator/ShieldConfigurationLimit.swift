import Foundation
import ManagedSettingsUI
import UIKit

struct ShieldConfigurationLimit {
  static func limitShield(
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
}
