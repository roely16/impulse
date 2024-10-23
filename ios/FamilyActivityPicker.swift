import Foundation
import SwiftUI
import FamilyControls
import ManagedSettingsUI
import SwiftData

struct ActivityPickerView: View {
  @State var selection = FamilyActivitySelection(includeEntireCategory: true)
  var isFirstSelection: Bool
  var blockId: String = ""
  var onSelectionChanged: (FamilyActivitySelection) -> Void
  @Environment(\.presentationMode) var presentationMode
  
  let selectionKey = "savedSelection"
  @State private var isSelectionSaved: Bool = false
  
  var body: some View {
    NavigationView {
      VStack {
        FamilyActivityPicker(selection: $selection)

        Text("Apps: \(selection.applications.count)")
              .padding()
              .font(.headline)

          Button(action: {
            saveSelection()
            onSelectionChanged(selection)
            isSelectionSaved = true
            presentationMode.wrappedValue.dismiss()
          }) {
            Text("Guardar")
                .fontWeight(.bold)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
          }
          .padding()
      }
      .onAppear {
        print(isSelectionSaved)
        if !isFirstSelection {
          print("load selection")
          loadSelection()
        } else if (blockId != "") {
          print("local selection from store")
          loadSelectionFromStore()
        }
      }
        .navigationBarTitle("Selecciona aplicaciones/sitios que distraen", displayMode: .inline)
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

      let configuration = ModelConfiguration(groupContainer: ( .identifier("group.com.impulsecontrolapp.impulse.share") ))
      let container = try ModelContainer(
        for: Block.self,
        configurations: configuration
      )
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
}

