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
final class LimitHistory {
  var id: UUID = UUID()
  var event: Event?
  var date: Date
  
  init(event: Event){
    self.id = UUID()
    self.date = Date()
    self.event = event
  }
}


