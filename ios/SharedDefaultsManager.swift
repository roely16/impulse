//
//  SharedDefaultsManager.swift
//  impulse
//
//  Created by Chur Herson on 30/11/24.
//

import Foundation
import ManagedSettings
import OSLog

enum TokenType {
    case application(ApplicationToken)
    case webDomain(WebDomainToken)
}

enum TokenActionType {
  case block
  case limit
}

class SharedDefaultsManager {
  
  private let sharedDefaults = UserDefaults(suiteName: Constants.SHARED_DEFAULT_GROUP)
  private var encoder = JSONEncoder()
  private var logger = Logger()

  func createTokenKeyString(token: TokenType, type: TokenActionType) -> String {
    do {
      let tokenData: Data
      switch token {
      case .application(let appToken):
          tokenData = try encoder.encode(appToken)
      case .webDomain(let webToken):
          tokenData = try encoder.encode(webToken)
      }
      let tokenString = String(data: tokenData, encoding: .utf8)
      
      // Validate if is block or limit
      switch type {
      case .block:
        return "\(tokenString ?? "")\(Constants.BLOCK_MONITOR_NAME)"
      case .limit:
        return "\(tokenString ?? "")\(Constants.LIMIT_MONITOR_NAME)"
      }
      
    } catch {
      logger.error("Impulse: Error trying to enconde app or web token")
    }
    return ""
  }
  
  func convertJsonToString(shareData: Any) throws -> Data? {
    do {
      let shareData = try JSONSerialization.data(withJSONObject: shareData, options: [])
      
      return shareData
    } catch {
      logger.error("Impulse: Error trying to convert json to string \(error.localizedDescription)")
      return nil
    }
  }
  
  func writeSharedDefaults(forKey: String, data: Any) throws {
    do {
      
      let sharedData = try convertJsonToString(shareData: data)
      sharedDefaults?.set(sharedData, forKey: forKey)
      sharedDefaults?.synchronize()
      
    } catch {
      logger.error("Impulse: Error trying to write on shared defaults \(error.localizedDescription)")
    }
  }
  
  func readSharedDefaultsByToken(token: TokenType, type: TokenActionType) throws -> [String: Any]? {
    do {
      
      let sharedDefaultKey: String
      
      switch token {
      case .application(let appToken):
        sharedDefaultKey = createTokenKeyString(token: .application(appToken), type: type)
      case .webDomain(let webToken):
        sharedDefaultKey = createTokenKeyString(token: .webDomain(webToken), type: type)
      }
      
      if let data = sharedDefaults?.data(forKey: sharedDefaultKey) {
        if let shieldConfigurationData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
          return shieldConfigurationData
        }
      }
    } catch {
      logger.error("Impulse: Error trying to read shared defaults \(error.localizedDescription)")
      throw error
    }
    
    return nil
  }
  
  func deleteSharedDefaultsByToken(token: TokenType, type: TokenActionType){
    let sharedDefaultKey: String
    
    switch token {
    case .application(let appToken):
      sharedDefaultKey = createTokenKeyString(token: .application(appToken), type: type)
    case .webDomain(let webToken):
      sharedDefaultKey = createTokenKeyString(token: .webDomain(webToken), type: type)
    }
    sharedDefaults?.removeObject(forKey: sharedDefaultKey)
    sharedDefaults?.synchronize()
  }
}
