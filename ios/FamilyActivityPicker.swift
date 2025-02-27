import Foundation
import SwiftUI
import FamilyControls
import ManagedSettingsUI
import SwiftData

struct ActivityPickerView: View {
  @State var selection = FamilyActivitySelection(includeEntireCategory: true)
  var isFirstSelection: Bool
  var blockId: String = ""
  var limitId: String = ""
  var saveButtonText: String = "Guardar"
  var titleText: String = "Selecciona aplicaciones/sitios que distraen"
  var onSelectionChanged: (FamilyActivitySelection) -> Void
  @Environment(\.presentationMode) var presentationMode
  
  let selectionKey = "savedSelection"
  @State private var isSelectionSaved: Bool = false
  
  var body: some View {
    NavigationView {
      VStack {
        FamilyActivityPicker(selection: $selection)

        Text("Apps: \(selection.applications.count) Webs: \(selection.webDomains.count)")
              .padding()
              .font(.headline)

          Button(action: {
            saveSelection()
            onSelectionChanged(selection)
            isSelectionSaved = true
            presentationMode.wrappedValue.dismiss()
          }) {
            Text(saveButtonText)
                .fontWeight(.bold)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
          }
          .padding()
      }
      .onAppear {
        print("on appear \(isFirstSelection) \(blockId) \(limitId)")
        if !isFirstSelection {
          print("load selection")
          loadSelection()
        } else if (blockId != "") {
          print("local selection from store")
          loadSelectionFromStore()
        } else if (limitId != "") {
          print("local limit selection from store")
          loadLimitSelectionFromStore()
        }
      }
        .navigationBarTitle(titleText, displayMode: .inline)
        .navigationBarItems(
          leading: Button(action: {
              presentationMode.wrappedValue.dismiss()
          }) {
              Image(systemName: "xmark")
                  .foregroundColor(.blue)
          }
        )
    }
  }
  
  func saveSelection() {
    do {
      let encodedSelection = try JSONEncoder().encode(selection)
      UserDefaults.standard.set(encodedSelection, forKey: selectionKey)
    } catch {
      print("Error guardando selección: \(error)")
    }
  }
  
  func loadSelection() {
    if let savedSelectionData = UserDefaults.standard.data(forKey: selectionKey) {
      do {
          let decodedSelection = try JSONDecoder().decode(FamilyActivitySelection.self, from: savedSelectionData)
          selection = decodedSelection
      } catch {
          print("Error cargando selección: \(error)")
      }
    }
  }
  
  @MainActor func loadSelectionFromStore () {
    do {
      guard let uuid = UUID(uuidString: blockId) else {
        print("Wrong block id")
        return
      }

      let container = try ModelConfigurationManager.makeConfiguration()
      let context = container.mainContext
      var fetchDescriptor = FetchDescriptor<Block>(
        predicate: #Predicate{ $0.id == uuid }
      )
      fetchDescriptor.fetchLimit = 1
      let result = try context.fetch(fetchDescriptor)
      let block = result.first
      selection = block?.familySelection ?? FamilyActivitySelection(includeEntireCategory: true)
    } catch {
      
    }
  }
  
  @MainActor func loadLimitSelectionFromStore () {
    do {
      guard let uuid = UUID(uuidString: limitId) else {
        print("Wrong block id")
        return
      }

      let container = try ModelConfigurationManager.makeConfiguration()
      let context = container.mainContext
      var fetchDescriptor = FetchDescriptor<Limit>(
        predicate: #Predicate{ $0.id == uuid }
      )
      fetchDescriptor.fetchLimit = 1
      let result = try context.fetch(fetchDescriptor)
      let limit = result.first
      selection = limit?.familySelection ?? FamilyActivitySelection(includeEntireCategory: true)
    } catch {
      print("Error trying to get limit data from store")
    }
  }
}

