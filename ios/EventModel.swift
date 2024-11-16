//
//  EventModel.swift
//  impulse
//
//  Created by Chur Herson on 26/10/24.
//

import Foundation
import SwiftData
import ManagedSettings

@Model
final class Event {
  var id: UUID = UUID()
  var limit: Limit?
  var appToken: ApplicationToken
  var opens: Int = 0
  
  @Relationship(deleteRule: .cascade, inverse: \LimitHistory.event)
  var history = [LimitHistory]()
  
  init(limit: Limit, appToken: ApplicationToken, opens: Int = 0){
    self.id = UUID()
    self.appToken = appToken
    self.limit = limit
    self.opens = opens
  }
}
