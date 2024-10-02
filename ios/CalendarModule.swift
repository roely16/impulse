import EventKit
import React

@objc(CalendarModule)
class CalendarModule: NSObject {

    private let eventStore = EKEventStore()

    @objc
    func addEvent(_ title: String, location: String, startDate: Double, endDate: Double, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        // Solicitar acceso al calendario
        eventStore.requestAccess(to: .event) { (granted, error) in
            if let error = error {
                reject("error", "Error requesting calendar access", error)
                return
            }
            
            if granted {
                let event = EKEvent(eventStore: self.eventStore)
                event.title = title
                event.location = location
                event.startDate = Date(timeIntervalSince1970: startDate)
                event.endDate = Date(timeIntervalSince1970: endDate)
                event.calendar = self.eventStore.defaultCalendarForNewEvents
                
                do {
                    try self.eventStore.save(event, span: .thisEvent)
                    resolve("Event added successfully")
                } catch let e {
                    reject("error", "Could not save event", e)
                }
            } else {
                reject("access_denied", "Access to calendar was denied", nil)
            }
        }
    }

    @objc static func requiresMainQueueSetup() -> Bool {
        return false
    }
}

