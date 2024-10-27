import Foundation
import FamilyControls
import DeviceActivity
import ManagedSettings
import React
import SwiftUI
import SwiftData

@objc(LimitModule)
class LimitModule: NSObject {
  
  var appsSelected: Set<ApplicationToken> = []
  var familySelection: FamilyActivitySelection = FamilyActivitySelection()
  
  private var container: ModelContainer?
  private var groupName = "group.com.impulsecontrolapp.impulse.share"
  
  override init() {
    super.init()
    do {
      // Inicializamos el contenedor una vez en el constructor
//      let configuration = ModelConfiguration(isStoredInMemoryOnly: false, allowsSave: true, groupContainer: .identifier("group.com.impulsecontrolapp.impulse.share"))
//      container = try ModelContainer(for: Limit.self, configurations: configuration)
    } catch {
      print("Error initializing ModelContainer: \(error)")
    }
  }
  
  @MainActor
  private func getContext() throws -> ModelContext {
    guard let container = container else {
      throw NSError(domain: "container_uninitialized", code: 500, userInfo: [NSLocalizedDescriptionKey: "ModelContainer is not initialized"])
    }
    return container.mainContext
  }
  
  @MainActor @objc
  func showAppPicker(_ isFirstSelection: Bool, blockId: String = "", resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    DispatchQueue.main.async {
      
      if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let window = scene.windows.first {
        
        let pickerView = ActivityPickerView(isFirstSelection: isFirstSelection, blockId: blockId) { updatedSelection in
          let applications = updatedSelection.applications
          self.appsSelected = updatedSelection.applicationTokens
          self.familySelection = updatedSelection
          print("Apps selected: \(updatedSelection.applications.count)")
          print("Categories selected: \(updatedSelection.categories.count)")
          print("Sites selected: \(updatedSelection.webDomains.count)")
          
          resolve([
            "status": "success",
            "appsSelected" : updatedSelection.applications.count,
            "categoriesSelected" : updatedSelection.categories.count,
            "sitesSelected" : updatedSelection.webDomains.count
          ])
        }
        
        let controller = UIHostingController(rootView: pickerView)
        controller.modalPresentationStyle = .fullScreen
        window.rootViewController?.present(controller, animated: true, completion: nil)
      } else {
          reject("Error", "Could not find the root window", nil)
      }
    }
  }
}

