import Foundation
import SwiftData
import ManagedSettings

@Model
final class WebEvent {
  var id: UUID = UUID()
  var limit: Limit?
  var webToken: WebDomainToken
  var opens: Int = 0
  
  @Relationship(deleteRule: .cascade, inverse: \WebEventHistory.event)
  var history = [WebEventHistory]()
  
  init(limit: Limit, webToken: WebDomainToken, opens: Int = 0){
    self.id = UUID()
    self.webToken = webToken
    self.limit = limit
    self.opens = opens
  }
}
