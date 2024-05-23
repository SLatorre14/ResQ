//
//  MAAD-Case.swift
//  pruebaApp
//
//  Created by Juan Sebastian Ibañez Capacho on 22/05/24.
//

import SwiftUI

struct MaadReportView: View {
    @State private var reportTitle = ""
    @State private var reportDescription = ""
    @State private var incidentDate = Date()
    @State private var isUrgent: Bool = false
    @State private var selectedCaseType = "" // Inicialmente vacío para forzar una selección
    @State private var showingAlert = false // Controla la visibilidad de la alerta

    let caseTypes = ["Select a Case Type", "Academic Misconduct", "Bullying", "Harassment", "Discrimination", "Other"]

    var body: some View {
        NavigationView {
            Form {
                
                Section(header: Text("Case Type")) {
                    Picker("Select Case Type", selection: $selectedCaseType) {
                        ForEach(caseTypes, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("Report Details")) {
                    TextField("Title", text: $reportTitle)
                        .foregroundColor(.black)
                    VStack{
                        HStack{Text("Descripcion:")
                        Spacer()}
                            .foregroundColor(.black)
                        TextEditor(text: $reportDescription)
                                            .frame(minHeight: 100, idealHeight: 150, maxHeight: .infinity) // Ajusta los parámetros de altura según necesites
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 5)
                                                    .stroke(Color.gray, lineWidth: 1)
                                            )
                        }
                    DatePicker("Incident Date", selection: $incidentDate, displayedComponents: .date)
                    Toggle("Urgent", isOn: $isUrgent)
                }

                

                Section {
                    Button("Submit Report") {
                        validateAndSubmitReport()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color("LighterGreen"))
                    .cornerRadius(10)
                }
            }
            .navigationTitle("Report MAAD Case")
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Incomplete Fields"), message: Text("Please fill in all required fields and select a case type."), dismissButton: .default(Text("OK")))
            }
        }
    }

    func validateAndSubmitReport() {
        // Verifica que todos los campos requeridos estén completos y que se haya seleccionado un tipo de caso válido
        if reportTitle.isEmpty || reportDescription.isEmpty || selectedCaseType.isEmpty || selectedCaseType == "Select a Case Type" {
            showingAlert = true // Muestra la alerta si los campos no están completos o no se ha seleccionado un tipo de caso
        } else {
            // Aquí iría la lógica para enviar los datos del formulario
            print("Report submitted: \(reportTitle), Case Type: \(selectedCaseType)")
            // Agregar más acciones si el formulario se envía correctamente
        }
    }
}

struct MaadReportView_Previews: PreviewProvider {
    static var previews: some View {
        MaadReportView()
    }
}



