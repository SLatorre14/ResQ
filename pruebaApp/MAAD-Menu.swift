//
//  MAAD-Menu.swift
//  pruebaApp
//
//  Created by Juan Sebastian Ibañez Capacho on 24/05/24.
//

import SwiftUI




struct ReportsMenuView: View {
    @State private var navigateToCreateReport = false
    @State private var navigateToViewReports = false
    @State private var showingAlert = false
    @ObservedObject var networkMonitor = NetworkMonitor()

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Button("Create a new Report") {
                    if networkMonitor.isConnected {
                        navigateToCreateReport = true
                    } else {
                        showingAlert = true
                    }
                }
                .buttonStyle(GreenButtonStyle())
                .background(NavigationLink("", destination: MaadReportView(), isActive: $navigateToCreateReport))

                Button("My Reports") {
                    if networkMonitor.isConnected {
                        navigateToViewReports = true
                    } else {
                        showingAlert = true
                    }
                }
                .buttonStyle(GreenButtonStyle())
                .background(NavigationLink("", destination: ReportsView(), isActive: $navigateToViewReports))

                if !networkMonitor.isConnected {
                    Text("No internet connection available")
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle("Reportes")
            .padding()
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("No Internet Connection"),
                    message: Text("You need to be connected to the internet to access this feature."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

struct GreenButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color("LighterGreen"))
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}



struct ReportsMenuView_Previews: PreviewProvider {
    static var previews: some View {
        ReportsMenuView()
    }
}
