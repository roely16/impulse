
//
//  LimitModel.swift
//  impulse
//
//  Created by Chur Herson on 11/10/24.
//

import SwiftData
import Foundation
import ManagedSettings
import FamilyControls

@Model
final class Limit {
  var id: UUID = UUID()
  var name: String
  var appsTokens: Set<ApplicationToken> = []
  var familySelection: FamilyActivitySelection?
  var timeLimit: String
  var openLimit: String
  var enable: Bool = true
  var weekdays: [Int] = []
  var enableImpulseMode: Bool = false
  var impulseTime: Int = 0
  var usageWarning: Int = 0
  
  @Relationship(deleteRule: .cascade, inverse: \Event.limit)
  var events = [Event]()
  
  init(
    name: String =  "",
    appsTokens: Set<ApplicationToken> = [],
    familySelection: FamilyActivitySelection = FamilyActivitySelection(includeEntireCategory: true),
    timeLimit: String = "",
    openLimit: String = "",
    enable: Bool = true,
    weekdays: [Int] = [],
    enableImpulseMode: Bool = false,
    impulseTime: Int = 0,
    usageWarning: Int = 0
  ) {
    self.id = UUID()
    self.name = name
    self.appsTokens = appsTokens
    self.familySelection = familySelection
    self.timeLimit = timeLimit
    self.openLimit = openLimit
    self.enable = enable
    self.weekdays = weekdays
    self.enableImpulseMode = enableImpulseMode
    self.impulseTime = impulseTime
    self.usageWarning = usageWarning
  }
}


