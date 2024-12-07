import Foundation
import SwiftData
import ManagedSettings

@Model
final class AppEvent {
  var id: UUID = UUID()
  var limit: Limit?
  var appToken: ApplicationToken
  var opens: Int = 0
  var status: EventStatus = EventStatus.warning
  
  @Relationship(deleteRule: .cascade, inverse: \AppEventHistory.event)
  var history = [AppEventHistory]()
  
  init(limit: Limit, appToken: ApplicationToken, opens: Int = 0, status: EventStatus){
    self.id = UUID()
    self.appToken = appToken
    self.limit = limit
    self.opens = opens
    self.status = status
  }
}
