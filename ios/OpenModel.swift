import SwiftData
import Foundation
import ManagedSettings

@Model
final class LimitOpen {
  var id: UUID = UUID()
  var appToken: ApplicationToken
  var date: Date
  
  init(date: Date = Date(), appToken: ApplicationToken) {
    self.appToken = appToken
    self.date = date
  }
}
