import Foundation
import SwiftData

struct ModelConfigurationManager {
  
  private static var container: ModelContainer?
  
  static func makeConfiguration() throws -> ModelContainer {
    let configuration = ModelConfiguration(
      isStoredInMemoryOnly: false,
      allowsSave: true,
      groupContainer: .identifier("group.com.impulsecontrolapp.impulse.share")
    )
    let container = try ModelContainer(
      for: Block.self,
      Limit.self,
      AppEvent.self,
      AppEventHistory.self,
      configurations: configuration
    )
    return container
  }
  
  @MainActor
  static func getContext() throws -> ModelContext {
    guard let container = container else {
      throw NSError(domain: "container_uninitialized", code: 500, userInfo: [NSLocalizedDescriptionKey: "ModelContainer is not initialized"])
    }
    return container.mainContext
  }
}
