import Foundation
import ManagedSettingsUI
import UIKit

struct ShieldConfigurationBlock {
  static func blockShield(applicationName: String = "", eventName: String = "") -> ShieldConfiguration{
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
}
