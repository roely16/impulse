import SwiftData
import Foundation
import ManagedSettings
import FamilyControls

@Model
final class Block {
  var id: UUID = UUID()      // SwiftData gestionará este ID como clave primaria
  var name: String
  var appsTokens: Set<ApplicationToken> = []
  var webDomainTokens: Set<WebDomainToken> = []
  var familySelection: FamilyActivitySelection?
  var startTime: String
  var endTime: String
  var enable: Bool = true
  var weekdays: [Int] = []
  
  init(
    name: String = "",
    appsTokens: Set<ApplicationToken> = [],
    webDomainTokens: Set<WebDomainToken> = [],
    familySelection: FamilyActivitySelection = FamilyActivitySelection(includeEntireCategory: true),
    startTime: String = "",
    endTime: String = "",
    enable: Bool = true,
    weekdays: [Int] = []
  ) {
    self.id = UUID()
    self.name = name
    self.appsTokens = appsTokens
    self.webDomainTokens = webDomainTokens
    self.familySelection = familySelection
    self.startTime = startTime
    self.endTime = endTime
    self.enable = enable
    self.weekdays = weekdays
  }
}
