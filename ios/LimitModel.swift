import SwiftData
import Foundation
import ManagedSettings
import FamilyControls

@Model
final class Limit {
  var id: UUID = UUID()
  var name: String
  var appsTokens: Set<ApplicationToken> = []
  var webDomainTokens: Set<WebDomainToken> = []
  var familySelection: FamilyActivitySelection?
  var timeLimit: String
  var openLimit: String
  var enable: Bool = true
  var weekdays: [Int] = []
  var impulseTime: Int = 0
  var usageWarning: Int = 0
  
  @Relationship(deleteRule: .cascade, inverse: \AppEvent.limit)
  var appsEvents = [AppEvent]()

  @Relationship(deleteRule: .cascade, inverse: \WebEvent.limit)
  var websEvents = [WebEvent]()
  
  init(
    name: String =  "",
    appsTokens: Set<ApplicationToken> = [],
    webDomainTokens: Set<WebDomainToken> = [],
    familySelection: FamilyActivitySelection = FamilyActivitySelection(includeEntireCategory: true),
    timeLimit: String = "",
    openLimit: String = "",
    enable: Bool = true,
    weekdays: [Int] = [],
    impulseTime: Int = 0,
    usageWarning: Int = 0
  ) {
    self.id = UUID()
    self.name = name
    self.appsTokens = appsTokens
    self.webDomainTokens = webDomainTokens
    self.familySelection = familySelection
    self.timeLimit = timeLimit
    self.openLimit = openLimit
    self.enable = enable
    self.weekdays = weekdays
    self.impulseTime = impulseTime
    self.usageWarning = usageWarning
  }
}
