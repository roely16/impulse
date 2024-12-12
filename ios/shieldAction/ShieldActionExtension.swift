import ManagedSettings
import Foundation
import OSLog
import ManagedSettings
import FamilyControls
import DeviceActivity
import SwiftData

// Override the functions below to customize the shield actions used in various situations.
// The system provides a default response for any functions that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class ShieldActionExtension: ShieldActionDelegate {
  
  private var logger = Logger()
  private var eventModel: AppEvent?
  private var webEventModel: WebEvent?
  private var container: ModelContainer
  private var sharedDefaultsManager = SharedDefaultsManager()
  
  override init() {
    do {
      container = try ModelConfigurationManager.makeConfiguration()
    } catch {
      fatalError("Error initializing ModelContainer: \(error)")
    }
    super.init()
  }
  
  @MainActor func getEvent(eventId: String) throws {
    do {
      guard let uuid = UUID(uuidString: eventId) else {
        throw NSError(domain: "Invalid UUID", code: 1, userInfo: nil)
      }

      let context = container.mainContext
      let fetchDescriptor = FetchDescriptor<AppEvent>(
        predicate: #Predicate{ $0.id == uuid }
      )
      let result = try context.fetch(fetchDescriptor)
      eventModel = result.first
    } catch {
      throw error
    }
  }
  
  @MainActor func getWebEvent(eventId: String) throws {
    do {
      guard let uuid = UUID(uuidString: eventId) else {
        throw NSError(domain: "Invalid UUID", code: 1, userInfo: nil)
      }

      let context = container.mainContext
      let fetchDescriptor = FetchDescriptor<WebEvent>(
        predicate: #Predicate{ $0.id == uuid }
      )
      let result = try context.fetch(fetchDescriptor)
      webEventModel = result.first
    } catch {
      throw error
    }
  }
    
  override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
      switch action {
      case .primaryButtonPressed:
        Task {
          do {
            logger.info("Impulse: pulse primary button")
            
            /* Block */
            if (try sharedDefaultsManager.readSharedDefaultsByToken(token: .application(application), type: .block)) != nil {
              logger.info("Impulse: resolve action for block")
              completionHandler(.close)
              return
            }
            
            /* Limit */
            if var shieldConfigurationData = try? sharedDefaultsManager.readSharedDefaultsByToken(token: .application(application), type: .limit) {
              do {
                let sharedDefaultManager = SharedDefaultsManager()
                
                let shieldButtonEnable = shieldConfigurationData["shieldButtonEnable"] as? Bool ?? true
                let eventId = shieldConfigurationData["eventId"] as? String ?? ""
                let impulseTime = shieldConfigurationData["impulseTime"] as? Int ?? 0
                
                if shieldButtonEnable {
                  
                  // Update event
                  try await getEvent(eventId: eventId)
                  eventModel?.opens += 1
                  try eventModel?.modelContext?.save()
                  
                  // Update shared defaults for app
                  shieldConfigurationData["opens"] = eventModel?.opens
                  shieldConfigurationData["shieldButtonEnable"] = false
                  let sharedDefaultKey = sharedDefaultManager.createTokenKeyString(token: .application(application), type: .limit)
                  try sharedDefaultManager.writeSharedDefaults(forKey: sharedDefaultKey, data: shieldConfigurationData)
                  completionHandler(.defer)
                  
                  // Create new monitor for app event
                  let usageWarning = self.eventModel?.limit?.usageWarning
                  
                  let monitorName = Constants.managedSettingsName(eventId: self.eventModel?.id.uuidString ?? "")
                  
                  logger.info("Impulse: create new monitor for event \(monitorName, privacy: .public)")
                  
                  let deviceActivityCenter = DeviceActivityCenter();
                  try deviceActivityCenter.startMonitoring(
                    DeviceActivityName(rawValue: monitorName),
                    during: DeviceActivitySchedule(
                      intervalStart: DateComponents(hour: 0, minute: 0),
                      intervalEnd: DateComponents(hour: 23, minute: 59),
                      repeats: false
                    ),
                    events: [DeviceActivityEvent.Name(rawValue: monitorName): DeviceActivityEvent(applications: [application], threshold: DateComponents(minute: usageWarning))]
                  )
                  
                  let managedSettingsName = Constants.managedSettingsName(eventId: eventId)
                  let store = ManagedSettingsStore(named: ManagedSettingsStore.Name(rawValue: managedSettingsName))
                                    
                  // Wait for unlock the app
                  if impulseTime > 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(impulseTime)) {
                      store.shield.applications = nil
                      self.logger.info("Impulse: Aplicaciones desbloqueadas después de \(impulseTime) segundos")
                      completionHandler(.close)
                    }
                  }
                  
                } else {
                  logger.info("Impulse: shield button is disabled")
                  completionHandler(.defer)
                }
              } catch {
                logger.error("Impulse: error when user clic shield primary button \(error.localizedDescription, privacy: .public)")
              }
              return
            }
            
            logger.info("Impulse: shield action without block or limit")
            completionHandler(.close)
          } catch {
            self.logger.error("Error in secondary action \(error.localizedDescription)")
          }
        }
      case .secondaryButtonPressed:
        completionHandler(.close)
      @unknown default:
          fatalError()
      }
    }
    
    override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
      switch action {
      case .primaryButtonPressed:
        Task {
          do {
            logger.info("Impulse: pulse primary button")
            
            /* Block */
            if (try sharedDefaultsManager.readSharedDefaultsByToken(token: .webDomain(webDomain), type: .block)) != nil {
              logger.info("Impulse: resolve action for block")
              completionHandler(.close)
              return
            }
            
            /* Limit */
            if var shieldConfigurationData = try? sharedDefaultsManager.readSharedDefaultsByToken(token: .webDomain(webDomain), type: .limit) {
              do {
                let sharedDefaultManager = SharedDefaultsManager()
                
                let shieldButtonEnable = shieldConfigurationData["shieldButtonEnable"] as? Bool ?? true
                let eventId = shieldConfigurationData["eventId"] as? String ?? ""
                let impulseTime = shieldConfigurationData["impulseTime"] as? Int ?? 0
                
                if shieldButtonEnable {
                  
                  // Update event
                  try await getWebEvent(eventId: eventId)
                  webEventModel?.opens += 1
                  try webEventModel?.modelContext?.save()
                  
                  // Update shared defaults for app
                  shieldConfigurationData["opens"] = webEventModel?.opens
                  shieldConfigurationData["shieldButtonEnable"] = false
                  let sharedDefaultKey = sharedDefaultManager.createTokenKeyString(token: .webDomain(webDomain), type: .limit)
                  try sharedDefaultManager.writeSharedDefaults(forKey: sharedDefaultKey, data: shieldConfigurationData)
                  completionHandler(.defer)
                  
                  // Create new monitor for app event
                  let usageWarning = self.webEventModel?.limit?.usageWarning
                  
                  let monitorName = Constants.managedSettingsName(eventId: self.webEventModel?.id.uuidString ?? "")
                  logger.info("Impulse: create new monitor for event \(monitorName, privacy: .public)")
                  let deviceActivityCenter = DeviceActivityCenter();
                  try deviceActivityCenter.startMonitoring(
                    DeviceActivityName(rawValue: monitorName),
                    during: DeviceActivitySchedule(
                      intervalStart: DateComponents(hour: 0, minute: 0),
                      intervalEnd: DateComponents(hour: 23, minute: 59),
                      repeats: false
                    ),
                    events: [DeviceActivityEvent.Name(rawValue: monitorName): DeviceActivityEvent(webDomains: [webDomain], threshold: DateComponents(minute: usageWarning))]
                  )
                  
                  let managedSettingsName = Constants.managedSettingsName(eventId: eventId)
                  let store = ManagedSettingsStore(named: ManagedSettingsStore.Name(rawValue: managedSettingsName))
                  
                  // Wait for unlock the app
                  if impulseTime > 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(impulseTime)) {
                      store.shield.webDomains = nil
                      self.logger.info("Impulse: web desbloqueadas después de \(impulseTime) segundos")
                      completionHandler(.close)
                    }
                  }
                  
                } else {
                  logger.info("Impulse: shield button is disabled")
                  completionHandler(.defer)
                }
              } catch {
                logger.error("Impulse: error when user clic shield primary button \(error.localizedDescription, privacy: .public)")
              }
              return
            }
            
            logger.info("Impulse: shield action without block or limit")
            completionHandler(.close)
          } catch {
            self.logger.error("Error in secondary action \(error.localizedDescription)")
          }
        }
      case .secondaryButtonPressed:
        completionHandler(.close)
      @unknown default:
          fatalError()
      }
    }
    
    override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        // Handle the action as needed.
        completionHandler(.close)
    }
}
