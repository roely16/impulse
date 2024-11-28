import Foundation
import SwiftData
import ManagedSettings

@Model
final class AppEventHistory {
  var id: UUID = UUID()
  var event: AppEvent
  var date: Date
  var status: EventStatus = EventStatus.warning
  
  init(event: AppEvent, status: EventStatus){
    self.id = UUID()
    self.date = Date()
    self.event = event
    self.status = status
  }
}
