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
            let monitorName = Constants.monitorNameWithFrequency(id: id, weekday: weekday, type: .block)
            
            let newActivityName = DeviceActivityName(rawValue: monitorName)
            
            try deviceActivityCenter.startMonitoring(
              newActivityName,
              during: activitySchedule
            )
            
            print("Impulse: create repeat monitor with name \(newActivityName.rawValue)")
         
          } catch {
            print("Impulse: error trying to create monitoring for block \(error.localizedDescription)")
          }
          
        }
        return
      }
      
      let activitySchedule = DeviceActivitySchedule(
        intervalStart: duration.intervalStart,
        intervalEnd: duration.intervalEnd,
        repeats: false
      )
      
      let monitorName = Constants.monitorName(id: id, type: .block)
      
      print("Impulse: create monitor with name \(monitorName)")
      
      let activityName = DeviceActivityName(rawValue: monitorName)
      
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
    
    print("Impulse: week schedule weekday \(weekday)")
    
    let startHour = duration.intervalStart.hour ?? 0
    let startMinute = duration.intervalStart.minute ?? 0
    let endHour = duration.intervalEnd.hour ?? 0
    let endMinute = duration.intervalEnd.minute ?? 0
    
    // Determinar si intervalEnd cruza al día siguiente
    var adjustedWeekday = weekday
    if endHour < startHour || (endHour == startHour && endMinute < startMinute) {
        adjustedWeekday = (weekday % 7) + 1 // Incrementar y ajustar al rango 1-7
    }
    
    print("Impulse: adjusted weekday \(adjustedWeekday)")
    
    let intervalStart = DateComponents(
      hour: duration.intervalStart.hour,
      minute: duration.intervalStart.minute,
      weekday: weekday
    )
    
    let intervalEnd = DateComponents(
      hour: duration.intervalEnd.hour,
      minute: duration.intervalEnd.minute,
      weekday: adjustedWeekday
    )
    
    let activitySchedule = DeviceActivitySchedule(
      intervalStart: intervalStart,
      intervalEnd: intervalEnd,
      repeats: true
    )
        
    return activitySchedule
  }
}
