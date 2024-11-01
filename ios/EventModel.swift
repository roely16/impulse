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
  
  @Relationship(deleteRule: .cascade, inverse: \LimitHistory.event)
  var history = [LimitHistory]()
  
  init(limit: Limit, appToken: ApplicationToken){
    self.id = UUID()
    self.appToken = appToken
    self.limit = limit
  }
}
