//
//  BlockModel.swift
//  impulse
//
//  Created by Chur Herson on 11/10/24.
//

import SwiftData
import Foundation
import ManagedSettings

@Model
final class Block {
  var id: UUID = UUID()      // SwiftData gestionará este ID como clave primaria
  var name: String
  var appsTokens: Set<ApplicationToken> = []
  var startTime: String
  var endTime: String
  var enable: Bool
  
  init(name: String, appsTokens: Set<ApplicationToken> = [], startTime: String, endTime: String, enable: Bool) {
    self.id = UUID()
    self.name = name
    self.appsTokens = appsTokens
    self.startTime = startTime
    self.endTime = endTime
    self.enable = enable
  }
}

