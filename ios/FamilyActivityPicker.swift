import SwiftUI
import FamilyControls
import ManagedSettingsUI

struct ActivityPickerView: View {
  @State var selection = FamilyActivitySelection(includeEntireCategory: true)
  var isFirstSelection: Bool
  var onSelectionChanged: (FamilyActivitySelection) -> Void
  @Environment(\.presentationMode) var presentationMode
  
  let selectionKey = "savedSelection"
  
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
        if !isFirstSelection {
          loadSelection()
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
}

