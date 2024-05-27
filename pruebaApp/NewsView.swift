//
//  NewsView.swift
//  pruebaApp
//
//  Created by user on 26/05/24.
//
import SwiftUI

struct NewsView: View {
    var body: some View {
        VStack {
            // Imagen de fondo
            Image("PlaceHolder")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            // Párrafo explicativo
            VStack {
                Spacer()
                Text("Este es el párrafo que explica la imagen. Aquí puedes proporcionar información detallada sobre lo que se muestra en la imagen.")
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                    .padding()
            }
        }
        .navigationTitle("Detalle de Imagen")
    }
}

struct NewsView_Previews: PreviewProvider {
    static var previews: some View {
        NewsView()
    }
}
