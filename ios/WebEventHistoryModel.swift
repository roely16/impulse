import Foundation
import SwiftData
import ManagedSettings

@Model
final class WebEventHistory {
  var id: UUID = UUID()
  var event: WebEvent
  var date: Date
  var status: EventStatus = EventStatus.warning
  
  init(event: WebEvent, status: EventStatus){
    self.id = UUID()
    self.date = Date()
    self.event = event
    self.status = status
  }
}
