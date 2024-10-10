import Foundation
import FamilyControls
import DeviceActivity
import ManagedSettings
import React
import SwiftUI

@objc(ScreenTimeModule)
class ScreenTimeModule: NSObject {
    
  var appsSelected: Set<ApplicationToken> = []
  let store = ManagedSettingsStore()
  
  func handleAuthorizationError(_ error: Error, reject: @escaping RCTPromiseRejectBlock) {
      let errorCode = "E_AUTHORIZATION_FAILED"
      let errorMessage = "Failed to request authorization: \(error.localizedDescription)"
      reject(errorCode, errorMessage, error)
  }

    @objc
    func requestAuthorization(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        if #available(iOS 16.0, *) {
            Task {
                do {
                    try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                    resolve(["status": "success", "message": "Authorization requested successfully."])
                } catch {
                    handleAuthorizationError(error, reject: reject)
                }
            }
        } else {
            reject("E_UNSUPPORTED_VERSION", "This functionality requires iOS 16.0 or higher.", nil)
        }
    }

    @objc(showAppPicker:rejecter:)
    func showAppPicker(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
      DispatchQueue.main.async {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
         let window = scene.windows.first {
          
          let pickerView = ActivityPickerView { updatedSelection in
            let applications = updatedSelection.applications
            self.appsSelected = updatedSelection.applicationTokens
            print("Aplicaciones seleccionadas: \(updatedSelection.applications.count)")
            resolve(["status": "success", "totalSelected" : updatedSelection.applications.count])
          }
          
          let controller = UIHostingController(rootView: pickerView)
          controller.modalPresentationStyle = .fullScreen
          window.rootViewController?.present(controller, animated: true, completion: nil)
        } else {
            reject("Error", "Could not find the root window", nil)
        }
      }
    }

  @objc
  func createBlock(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    print("create block")
    store.shield.applications = self.appsSelected
    resolve(["status": "success", "appsBlocked": self.appsSelected.count])
  }
  
  @objc static func requiresMainQueueSetup() -> Bool {
      return true
  }
}

