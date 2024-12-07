import Foundation
import DeviceActivity

class MonitorUtils {
  
  private let deviceActivityCenter = DeviceActivityCenter()
  
  func startMonitoring(
    id: String = "",
    duration: DeviceActivitySchedule,
    weekdays: [Int] = []
  ){
    do {
      
      let requireRepeat = weekdays.count > 0
      
      if requireRepeat {
        weekdays.forEach{weekday in
          
          do {
            let activitySchedule = createWeekSchedule(weekday: weekday, duration: duration)
            let name = Constants.monitorNameWithFrequency(id: id, weekday: weekday, type: .block)
            let newActivityName = DeviceActivityName(rawValue: name)
            
            try deviceActivityCenter.startMonitoring(
              newActivityName,
              during: activitySchedule
            )
            
            print("Impulse: create monitor with name \(newActivityName.rawValue)")
         
          } catch {
            print("Impulse: error trying to create monitoring for block")
          }
          
        }
        return
      }
      
      let activitySchedule = DeviceActivitySchedule(
        intervalStart: duration.intervalStart,
        intervalEnd: duration.intervalEnd,
        repeats: false
      )
      
      let activityId = Constants.monitorName(id: id, type: .block)
      let activityName = DeviceActivityName(rawValue: activityId)
      
      try deviceActivityCenter.startMonitoring(
        activityName,
        during: activitySchedule
      )
    } catch  {
      print("Impulse: error trying to start monitoring \(error.localizedDescription)")
    }
  }
  
  func stopMonitoring(monitorName: String){
    deviceActivityCenter.stopMonitoring([DeviceActivityName(rawValue: monitorName)])
  }
  
  func createWeekSchedule(weekday: Int = 0, duration: DeviceActivitySchedule) -> DeviceActivitySchedule{
    
    let intervalStart = DateComponents(
      hour: duration.intervalStart.hour,
      minute: duration.intervalStart.minute,
      weekday: weekday
    )
    
    let intervalEnd = DateComponents(
      hour: duration.intervalEnd.hour,
      minute: duration.intervalEnd.minute,
      weekday: weekday
    )
    
    let activitySchedule = DeviceActivitySchedule(
      intervalStart: intervalStart,
      intervalEnd: intervalEnd,
      repeats: true
    )
        
    return activitySchedule
  }
}
