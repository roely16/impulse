import Foundation

enum Constants {
  
  static let BLOCK_MONITOR_NAME = "-block"
  static let BLOCK_MONITOR_NAME_WITH_FREQUENCY = "\(BLOCK_MONITOR_NAME)-day-"
  
  static func blockMonitorName(blockId: String = "") -> String{
    return "\(blockId)\(BLOCK_MONITOR_NAME)"
  }
  
  static func blockMonitorNameWithFrequency(blockId: String = "", weekday: Int = 0) -> String{
    return "\(blockId)\(BLOCK_MONITOR_NAME_WITH_FREQUENCY)\(weekday)"
  }
  
  static func extractIdForBlock(from activityRawValue: String) -> String {

    if let range = activityRawValue.range(of: BLOCK_MONITOR_NAME) {
      return String(activityRawValue[..<range.lowerBound])
    }
    
    return activityRawValue
  }
  
}
