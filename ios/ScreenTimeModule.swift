import Foundation
import FamilyControls
import DeviceActivity
import ManagedSettings
import React
import SwiftUI

@objc(ScreenTimeModule)
class ScreenTimeModule: NSObject {
  
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

  
  @objc
  func requestAuthorization(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    AuthorizationCenter.shared.requestAuthorization { result in
      switch result {
      case .success:
        resolve("Authorization successful")
      case .failure(let error):
        reject("AuthorizationError", "Authorization failed", error)
      }
    }
  }

  @objc(showAppPicker:rejecter:)
  func showAppPicker(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
      DispatchQueue.main.async {
          if let window = UIApplication.shared.keyWindow {
              var selectedActivity = FamilyActivitySelection() // Variable para almacenar la selección
              let pickerView = ActivityPickerView(selectedActivity: .constant(selectedActivity))
              let controller = UIHostingController(rootView: pickerView)
              window.rootViewController?.present(controller, animated: true, completion: {
                  resolve("App Picker Presented")
              })
          } else {
              reject("Error", "Could not find the root window", nil)
          }
      }
  }




  
  @objc static func requiresMainQueueSetup() -> Bool {
      return true
  }
}
