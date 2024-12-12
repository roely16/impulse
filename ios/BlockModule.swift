import Foundation
import SwiftData
import DeviceActivity
import ManagedSettings
import React

@objc(BlockModule)
class BlockModule: NSObject {
  
  private var container: ModelContainer?
  
  override init() {
    super.init()
    do {
      container = try ModelConfigurationManager.makeConfiguration()
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
  func getBlocks(
    _ resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    do {
      let context = try getContext()
      
      let fetchDescriptor = FetchDescriptor<Block>()
      let blocks = try context.fetch(fetchDescriptor)
      
      let blocksArray = blocks.map { block -> [String: Any] in
        return [
            "id": block.id.uuidString,
            "title": block.name,
            "subtitle": "\(block.startTime)-\(block.endTime)",
            "apps": block.appsTokens.count,
            "sites": block.webDomainTokens.count,
            "weekdays": block.weekdays,
            "enable": block.enable
        ]
      }
      resolve(["status": "success", "blocks" : blocksArray])
    } catch {
      print("Error getting blocks", error.localizedDescription)
    }
  }
  
  @MainActor @objc
  func deleteBlock(
    _ blockId: String,
    resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    do {
      guard let uuid = UUID(uuidString: blockId) else {
        reject("invalid_uuid", "El blockId proporcionado no es un UUID válido.", nil)
        return
      }
  
      let context = try getContext()
      
      // Stop monitoring
      var fetchDescriptor = FetchDescriptor<Block>(
        predicate: #Predicate{ $0.id == uuid }
      )
      fetchDescriptor.fetchLimit = 1
      let result = try context.fetch(fetchDescriptor)
      let block = result.first
      
      let deviceActivityCenter = DeviceActivityCenter();
      
      if block?.weekdays.count == 0 {
        deviceActivityCenter.stopMonitoring([DeviceActivityName(rawValue: blockId)])
      } else {
        let deviceActivityNames: [DeviceActivityName] = block?.weekdays.map { weekday in DeviceActivityName(rawValue: "\(blockId)-day-\(weekday)") } ?? []
        deviceActivityCenter.stopMonitoring(deviceActivityNames)
        print(deviceActivityNames)
      }
      
      // Remove restriction
      let store = ManagedSettingsStore(named: ManagedSettingsStore.Name(rawValue: blockId))
      store.shield.applications = nil
      store.shield.webDomains = nil
      
      // Delete from store
      try context.delete(model: Block.self, where: #Predicate { $0.id == uuid })
      
      // TODO
      // - Delete shared defaults
      resolve("Block deleted")
    } catch {
      reject("Error", "Could not delete block", nil)
    }
  }
  
  @MainActor @objc
  func getBlock(
    _ blockId: String,
    resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    do {
      guard let uuid = UUID(uuidString: blockId) else {
        reject("invalid_uuid", "El blockId proporcionado no es un UUID válido.", nil)
        return
      }
      
      let context = try getContext()
      
      var fetchDescriptor = FetchDescriptor<Block>(
        predicate: #Predicate{ $0.id == uuid }
      )
      fetchDescriptor.fetchLimit = 1
      let result = try context.fetch(fetchDescriptor)
      let block = result.first
      
      let blockData = [
        "id": block?.id.uuidString,
        "name": block?.name,
        "startTime": block?.startTime,
        "endTime": block?.endTime,
        "apps": block?.appsTokens.count,
        "sites": block?.webDomainTokens.count,
        "weekdays": block?.weekdays
      ] as [String : Any]

      resolve(["status": "success", "block" : blockData])
    } catch {
      reject("Error", "Could not delete block", nil)
    }
  }
  
  @MainActor @objc
  func updateBlockStatus(
    _ blockId: String,
    isEnable: Bool,
    resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    do {
      guard let uuid = UUID(uuidString: blockId) else {
        reject("invalid_uuid", "El blockId proporcionado no es un UUID válido.", nil)
        return
      }
      let deviceActivityCenter = DeviceActivityCenter();
      
      let context = try getContext()
      
      let fetchDescriptor = FetchDescriptor<Block>(
        predicate: #Predicate { $0.id == uuid }
      )
      let result = try context.fetch(fetchDescriptor)
      let block = result.first

      block?.enable = isEnable
      
      if !isEnable {
        // Stop monitoring
        if block?.weekdays.count == 0 {
          let monitorName = Constants.monitorName(id: blockId, type: .block)
          deviceActivityCenter.stopMonitoring([DeviceActivityName(rawValue: monitorName)])
        } else {
          let deviceActivityNames: [DeviceActivityName] = block?.weekdays.map { weekday in DeviceActivityName(rawValue: Constants.monitorNameWithFrequency(id: blockId, weekday: weekday, type: .block)) } ?? []
          deviceActivityCenter.stopMonitoring(deviceActivityNames)
          print(deviceActivityNames)
        }

      } else {
        let startTimeComponents = block?.startTime.split(separator: ":") ?? []
        let endTimeComponents = block?.endTime.split(separator: ":") ?? []
        let weekdays = block?.weekdays ?? []
        
        if weekdays.count == 0 {
          let monitorName = Constants.monitorName(id: blockId, type: .block)
          
          try deviceActivityCenter.startMonitoring(
            DeviceActivityName(rawValue: monitorName),
            during: DeviceActivitySchedule(
              intervalStart: DateComponents(hour: Int(startTimeComponents[0]), minute: Int(startTimeComponents[1])),
              intervalEnd: DateComponents(hour: Int(endTimeComponents[0]), minute: Int(endTimeComponents[1])),
              repeats: false
            )
          )
          print("Only one time \(blockId)")
        } else {
          for weekday in weekdays {
            
            let monitorName = Constants.monitorNameWithFrequency(id: blockId, weekday: weekday, type: .block)
            
            try deviceActivityCenter.startMonitoring(
              DeviceActivityName(rawValue: monitorName),
              during: DeviceActivitySchedule(
                intervalStart: DateComponents(hour: Int(startTimeComponents[0]), minute: Int(startTimeComponents[1]), weekday: weekday),
                intervalEnd: DateComponents(hour: Int(endTimeComponents[0]), minute: Int(endTimeComponents[1]), weekday: weekday),
                repeats: true
              )
            )
            print("Repeat on \(weekday) \(blockId)")
          }
        }
      }
      
      try context.save()

      resolve([
        "status": "success",
        "blockId" : blockId,
        "isEnable": isEnable,
        "blockName": block?.name
      ])
    } catch {
      print("Error updating block status")
    }
  }
  
}
