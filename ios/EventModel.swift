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
  var limit: Limit
  var appToken: ApplicationToken
  
  init(limit: Limit, appToken: ApplicationToken){
    self.id = UUID()
    self.appToken = appToken
    self.limit = limit
  }
}
