//
//  MAAD-Case.swift
//  pruebaApp
//
//  Created by Juan Sebastian Ibañez Capacho on 22/05/24.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

struct MaadReportView: View {
    @AppStorage("reportTitle") private var reportTitle = ""
    @AppStorage("reportDescription") private var reportDescription = ""
    @AppStorage("selectedCaseType") private var selectedCaseType = ""

    @State private var incidentDate = Date()
    @State private var showingAlert = false

    let caseTypes = ["Select a Case Type", "Academic Misconduct", "Bullying", "Harassment", "Discrimination", "Other"]
    
    private var db = Firestore.firestore()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Case Type")) {
                    Picker("Select Case Type", selection: $selectedCaseType) {
                        ForEach(caseTypes, id: \.self) { caseType in
                            Text(caseType)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .foregroundColor(.black)
                }
                
                Section(header: Text("Report Details")) {
                    TextField("Title", text: $reportTitle)
                        .foregroundColor(.black)
                    TextEditor(text: $reportDescription)
                        .foregroundColor(.black)
                        .frame(minHeight: 100, idealHeight: 150, maxHeight: .infinity)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    DatePicker("Incident Date", selection: $incidentDate, displayedComponents: .date)
                        .foregroundColor(.black)
                        .onChange(of: incidentDate) { newValue in
                            UserDefaults.standard.set(newValue, forKey: "incidentDate")
                        }
                }

                Section {
                    Button("Submit Report") {
                        validateAndSubmitReport()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("LightGreen"))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .navigationTitle("Report MAAD Case")
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Empty fields"), message: Text("Please fill in all required fields and select a case type."), dismissButton: .default(Text("OK")))
            }
        }
    }

    func validateAndSubmitReport() {
        if reportTitle.isEmpty || reportDescription.isEmpty || selectedCaseType.isEmpty || selectedCaseType == "Select a Case Type" {
            showingAlert = true
        } else {
            let userEmail = Auth.auth().currentUser?.email ?? "Unknown email"
            let data: [String: Any] = [
                "title": reportTitle,
                "description": reportDescription,
                "incidentDate": incidentDate,
                "caseType": selectedCaseType,
                "status": "Pending",
                "userEmail": userEmail
            ]
            
            db.collection("reports").addDocument(data: data) { error in
                if let error = error {
                    print("Error writing document: \(error)")
                } else {
                    print("Document successfully written!")
                }
            }
            reportTitle = ""
            reportDescription = ""
            selectedCaseType = ""
            incidentDate = Date()
            
            
        }
    }
}

struct MaadReportView_Previews: PreviewProvider {
    static var previews: some View {
        MaadReportView()
    }
}

