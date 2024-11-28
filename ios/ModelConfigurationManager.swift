import Foundation
import SwiftData

struct ModelConfigurationManager {
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
}
