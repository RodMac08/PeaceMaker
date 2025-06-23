//
//  BreathingView.swift
//  PeaceMaker
//
//  Created by Rodrigo Macias Ruiz on 15/06/25.
//

import SwiftUI

// Vista para la sesión de respiración guiada.
// Muestra una animación circular con temporizador, sonido de fondo y mensaje final.
struct BreathingView: View {
    // Ruido preferido del usuario para reproducir durante la sesión.
    @AppStorage("userNoise") var userNoise: String = "Blanco"

    // Acción que se ejecuta al finalizar la sesión.
    var onFinish: () -> Void

    // Controla la visibilidad de la vista.
    @Environment(\.presentationMode) var presentationMode

    // Escala animada del círculo de respiración.
    @State private var breathScale: CGFloat = 1.0

    // Activa o desactiva la animación de respiración.
    @State private var animate = false

    // Tiempo restante de la sesión en segundos.
    @State private var sessionTimeRemaining: Int = 60

    // Temporizador de cuenta regresiva.
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // Duración de un ciclo de respiración.
    private let breathDuration: Double = 4.0

    // Contenido visual de la vista.
    // Muestra fondo, animación, temporizador y botón para cerrar la sesión.
    var body: some View {
        ZStack {
            getSavedBackgroundImage()?
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack {
                Spacer()

                VStack(spacing: 12) {
                    Text(timeString)
                        .font(.system(size: 36, weight: .light, design: .monospaced))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.6), radius: 4, x: 0, y: 2)
                        .padding(.top, 32)

                    Text("Respira profundamente")
                        .font(.title2)
                        .padding()

                    Circle()
                        .stroke(Color.white, lineWidth: 4)
                        .frame(width: 150 * breathScale, height: 150 * breathScale)
                        .animation(.easeInOut(duration: breathDuration).repeatForever(autoreverses: true), value: breathScale)
                        .onAppear {
                            animate.toggle()
                            breathScale = animate ? 1.5 : 1.0
                        }
                }

                Spacer()

                Button("Parar sesión") {
                    presentationMode.wrappedValue.dismiss()
                    SoundManager.shared.stop()
                }
                .foregroundColor(.white)
                .shadow(color: .white, radius: 3)
                .padding(.bottom, 40)
            }
        }
        .backgroundFromUserDefaults()
        .onAppear {
            SoundManager.shared.play(noiseType: userNoise)
        }
        .onDisappear {
            SoundManager.shared.stop()
        }
        .onReceive(timer) { _ in
            if sessionTimeRemaining > 0 {
                sessionTimeRemaining -= 1
                if sessionTimeRemaining == 0 {
                    presentationMode.wrappedValue.dismiss()
                    onFinish()
                }
            }
        }
    }

    // Formato del tiempo restante como mm:ss.
    private var timeString: String {
        let minutes = sessionTimeRemaining / 60
        let seconds = sessionTimeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
