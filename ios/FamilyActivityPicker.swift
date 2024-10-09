import SwiftUI
import FamilyControls

struct ActivityPickerView: View {
    @Binding var selectedActivity: FamilyActivitySelection

    var body: some View {
        VStack {
            FamilyActivityPicker(selection: $selectedActivity)
            .padding()
            
            Button(action: {
                // Acción para guardar la actividad seleccionada
                saveActivitySelection(selectedActivity)
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

    private func saveActivitySelection(_ selection: FamilyActivitySelection) {
        // Lógica para guardar la actividad seleccionada
        print("Actividad guardada: ")
        // Puedes agregar más lógica para manejar el guardado de datos
    }
}

