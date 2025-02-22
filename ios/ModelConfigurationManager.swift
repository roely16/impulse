import Foundation
import SwiftData

struct ModelConfigurationManager {
  
  private static var container: ModelContainer?

  static func makeConfiguration() throws -> ModelContainer {
    if let existingContainer = container {
      return existingContainer
    }

    let configuration = ModelConfiguration("local",
      isStoredInMemoryOnly: false,
      allowsSave: true,
      groupContainer: .identifier("group.com.impulsecontrolapp.impulse.share"),
      cloudKitDatabase: .none
    )

    print("Model container is initialized")
    let newContainer = try ModelContainer(
      for: Block.self,
      Limit.self,
      AppEvent.self,
      AppEventHistory.self,
      WebEvent.self,
      WebEventHistory.self,
      configurations: configuration
    )

    container = newContainer // Guardar la instancia para reutilización
    return newContainer
  }
  
  @MainActor
  static func getContext() throws -> ModelContext {
    guard let container = container else {
      throw NSError(domain: "container_uninitialized", code: 500, userInfo: [NSLocalizedDescriptionKey: "ModelContainer is not initialized"])
    }
    return container.mainContext
  }
  
  static func getContainer() throws -> ModelContainer {
    guard let container = container else {
      throw NSError(domain: "container_uninitialized", code: 500, userInfo: [NSLocalizedDescriptionKey: "ModelContainer is not initialized"])
    }
    return container
  }
}

