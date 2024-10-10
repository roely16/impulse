import SwiftUI
import FamilyControls
import ManagedSettingsUI

struct ActivityPickerView: View {
    @State var selection = FamilyActivitySelection()
    var onSelectionChanged: (FamilyActivitySelection) -> Void
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            FamilyActivityPicker(selection: $selection)

            Text("Aplicaciones seleccionadas: \(selection.applications.count).")
                .padding()
                .font(.headline)

            Button(action: {
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
    }
}

