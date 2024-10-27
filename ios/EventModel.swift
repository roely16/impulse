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
  var limitId: UUID
  var appToken: ApplicationToken
  
  init(limitId: UUID, appToken: ApplicationToken){
    self.id = UUID()
    self.limitId = limitId
    self.appToken = appToken
  }
}
