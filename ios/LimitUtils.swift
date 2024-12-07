import Foundation
import ManagedSettings

class LimitUtils {
  
  private let sharedDefaultsManager = SharedDefaultsManager()
  
  func clearManagedSettingsByEvent(event: AppEvent) {
    let managedSettingsName = Constants.managedSettingsName(eventId: event.id.uuidString)
    let store = ManagedSettingsStore(named: ManagedSettingsStore.Name(rawValue: managedSettingsName))
    store.clearAllSettings()
  }
  
  func deleteAllSharedDefaults(event: AppEvent){
    sharedDefaultsManager.deleteSharedDefaultsByToken(token: .application(event.appToken), type: .limit)
    sharedDefaultsManager.deleteSharedDefaultsByToken(token: .application(event.appToken), type: .block)
  }
  
}
