//
//  MAAD-Reports.swift
//  pruebaApp
//
//  Created by Juan Sebastian Ibañez Capacho on 24/05/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore

class ReportsViewModel: ObservableObject {
    @Published var reports = [Report]()
    @Published var isLoading = false
    @Published var errorMessage = ""
    private var hasFetchedData = false

    @MainActor
    func fetchUserReports() async {
        guard !hasFetchedData else { return }
        guard let userEmail = Auth.auth().currentUser?.email else {
            errorMessage = "No user email found, user might not be logged in"
            print(errorMessage)
            return
        }

        isLoading = true
        errorMessage = ""
        defer { isLoading = false }

        do {
            let documentsSnapshot = try await FirebaseManager.shared.firestore.collection("reports")
                .whereField("userEmail", isEqualTo: userEmail)
                .getDocuments()

            var newReports = [Report]()
            for document in documentsSnapshot.documents {
                let data = document.data()
                let id = document.documentID
                let title = data["title"] as? String ?? ""
                let description = data["description"] as? String ?? ""
                let incidentDate = (data["incidentDate"] as? Timestamp)?.dateValue() ?? Date()
                let caseType = data["caseType"] as? String ?? ""
                let status = data["status"] as? String ?? ""

                let report = Report(id: id, title: title, description: description, incidentDate: incidentDate, caseType: caseType, status: status, userEmail: userEmail)
                newReports.append(report)
            }
            self.reports = newReports
            hasFetchedData = true 
            print("Reports fetched successfully.")
        } catch {
            print("Error getting documents: \(error)")
            errorMessage = "Failed to fetch reports: \(error.localizedDescription)"
        }
    }
}


struct Report: Identifiable {
    var id: String
    var title: String
    var description: String
    var incidentDate: Date
    var caseType: String
    var status: String
    var userEmail: String
}





struct ReportsView: View {
    @ObservedObject var viewModel = ReportsViewModel()

    var body: some View {
        NavigationView {
            if viewModel.isLoading {
                ProgressView("Loading reports...")
                    .foregroundColor(.black)
            } else if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundColor(.red)
            } else {
                List(viewModel.reports) { report in
                    reportCardView(report: report)
                }
                .navigationTitle("My Reports")
                .onAppear {
                    Task {
                        await viewModel.fetchUserReports()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func reportCardView(report: Report) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(report.title)
                .font(.headline)
                .foregroundColor(.black)
                .padding()
               

            Text(report.description)
                .font(.subheadline)
                .foregroundColor(.black)
                .padding()
                

            Text("Date: \(report.incidentDate, formatter: itemFormatter)")
                .font(.caption)
                .foregroundColor(.black)
                .padding()
                

            Text("Case Type: \(report.caseType)")
                .font(.caption)
                .foregroundColor(.black)
                .padding()
                

            Text("Status: \(report.status)")
                .font(.caption)
                .foregroundColor(.black)
                .padding()
                
        }
        .padding(.vertical, 5)
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()

struct ReportsView_Previews: PreviewProvider {
    static var previews: some View {
        ReportsView()
    }
}




struct RReportsView_Previews: PreviewProvider {
    static var previews: some View {
        ReportsView()
    }
}
