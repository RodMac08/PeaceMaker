//
//  InfoView.swift
//  PeaceMaker
//
//  Created by Rodrigo Macias Ruiz on 21/06/25.
//


import SwiftUI

struct InfoView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Group {
                Text("Rodrigo Macias Ruiz")
                Text("Versión 1.0.0")
                Text("API para IA utilizada:")
                Text("Together.ai con Mistral 7B Instruct")
                Text("Información escolar:")
                Text("Instituto Tecnológico de la Laguna")
                Text("Ingeniería en sistemas computacionales")

            }
            .foregroundColor(.white)
            .font(.headline)
            .multilineTextAlignment(.center)

            Spacer()

            Image("logoApp")
                .resizable()
                .scaledToFit()
                .frame(width: 360, height: 360)
                .padding()

            Spacer()
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
    }
}
