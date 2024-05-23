//
//  MAAD-Case.swift
//  pruebaApp
//
//  Created by Juan Sebastian Ibañez Capacho on 22/05/24.
//

import SwiftUI

struct MaadReportView: View {
    @AppStorage("reportTitle") private var reportTitle = ""
    @AppStorage("reportDescription") private var reportDescription = ""
    @AppStorage("isUrgent") private var isUrgent = false
    @AppStorage("selectedCaseType") private var selectedCaseType = "" // Inicialmente vacío para forzar una selección

    @State private var incidentDate = Date()
    @State private var showingAlert = false // Controla la visibilidad de la alerta

    let caseTypes = ["Select a Case Type", "Academic Misconduct", "Bullying", "Harassment", "Discrimination", "Other"]

    init() {
        if let savedDate = UserDefaults.standard.object(forKey: "incidentDate") as? Date {
            _incidentDate = State(initialValue: savedDate)
        }
    }

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
                    VStack {
                        HStack { Text("Description:")
                            Spacer()
                        }
                        .foregroundColor(.black)
                        TextEditor(text: $reportDescription)
                            .frame(minHeight: 100, idealHeight: 150, maxHeight: .infinity)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                    }
                    DatePicker("Incident Date", selection: $incidentDate, displayedComponents: .date)
                        .onChange(of: incidentDate) { newValue in
                            UserDefaults.standard.set(newValue, forKey: "incidentDate")
                        }
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
                Alert(title: Text("Campos incompletos"), message: Text("Please fill in all required fields and select a case type."), dismissButton: .default(Text("OK")))
            }
        }
    }

    func validateAndSubmitReport() {
        if reportTitle.isEmpty || reportDescription.isEmpty || selectedCaseType.isEmpty || selectedCaseType == "Select a Case Type" {
            showingAlert = true
        } else {
            print("Report submitted: \(reportTitle), Case Type: \(selectedCaseType)")
        }
    }
}

struct MaadReportView_Previews: PreviewProvider {
    static var previews: some View {
        MaadReportView()
    }
}
