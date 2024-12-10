import Foundation
import ManagedSettings

class LimitUtils {
  
  private let sharedDefaultsManager = SharedDefaultsManager()
  
  func clearManagedSettingsByEvent(eventId: String) {
    let managedSettingsName = Constants.managedSettingsName(eventId: eventId)
    let store = ManagedSettingsStore(named: ManagedSettingsStore.Name(rawValue: managedSettingsName))
    store.clearAllSettings()
  }
  
  func deleteAllSharedDefaults(event: AppEvent){
    sharedDefaultsManager.deleteSharedDefaultsByToken(token: .application(event.appToken), type: .limit)
    sharedDefaultsManager.deleteSharedDefaultsByToken(token: .application(event.appToken), type: .block)
  }
  
  func deleteAllSharedDefaultsWeb(event: WebEvent){
    sharedDefaultsManager.deleteSharedDefaultsByToken(token: .webDomain(event.webToken), type: .limit)
    sharedDefaultsManager.deleteSharedDefaultsByToken(token: .webDomain(event.webToken), type: .block)
  }
  
}
