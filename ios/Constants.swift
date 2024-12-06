import Foundation

enum MonitorType {
  case block
  case limit
}

enum Constants {
  
  static let SHARED_DEFAULT_GROUP = "group.com.impulsecontrolapp.impulse.share"
  
  static let BLOCK_MONITOR_NAME = "-block"
  static let BLOCK_MONITOR_NAME_WITH_FREQUENCY = "\(BLOCK_MONITOR_NAME)-day-"
  
  static let LIMIT_MONITOR_NAME = "-limit"
  static let LIMIT_MONITOR_NAME_WITH_FREQUENCY = "\(LIMIT_MONITOR_NAME)-day-"
  
  static let EVENT_MANAGED_SETTINGS_STORE_IDENTIFIER = "-event"
  
  static func monitorName(id: String = "", type: MonitorType) -> String{
    switch type {
    case .block:
      return "\(id)\(BLOCK_MONITOR_NAME)"
    case .limit:
      return "\(id)\(LIMIT_MONITOR_NAME)"
    }
  }
  
  static func monitorNameWithFrequency(id: String = "", weekday: Int = 0, type: MonitorType) -> String{
    switch type {
    case .block:
      return "\(id)\(BLOCK_MONITOR_NAME_WITH_FREQUENCY)\(weekday)"
    case .limit:
      return "\(id)\(LIMIT_MONITOR_NAME_WITH_FREQUENCY)\(weekday)"
    }
  }
  
  static func blockSharedDefaultsName(tokenString: String) -> String {
    return "\(tokenString)\(BLOCK_MONITOR_NAME)"
  }
  
  static func managedSettingsName(eventId: String) -> String {
    return "\(eventId)\(EVENT_MANAGED_SETTINGS_STORE_IDENTIFIER)"
  }
  
  static func extractIdForBlock(from activityRawValue: String) -> String {

    if let range = activityRawValue.range(of: BLOCK_MONITOR_NAME) {
      return String(activityRawValue[..<range.lowerBound])
    }
    
    return activityRawValue
  }
  
  static func extractIdForLimit(from activityRawValue: String) -> String {
    if let range = activityRawValue.range(of: LIMIT_MONITOR_NAME) {
      return String(activityRawValue[..<range.lowerBound])
    }

    return activityRawValue
  }
  
}
