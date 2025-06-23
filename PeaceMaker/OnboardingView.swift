//
//  OnboardingView.swift
//  PeaceMaker
//
//  Created by Rodrigo Macias Ruiz on 18/06/25.
//

import SwiftUI

// Vista inicial de configuración donde el usuario proporciona su información personal.
// Se muestra solo la primera vez que se abre la aplicación.
struct OnboardingView: View {
    // Estado de si el usuario ya completó el onboarding.
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    // Nombre del usuario.
    @AppStorage("userName") var userName = ""
    // Apellido del usuario.
    @AppStorage("userLastName") var userLastName = ""
    // Fecha de nacimiento del usuario.
    @AppStorage("userBirthDate") var userBirthDate = Date()
    // Género del usuario.
    @AppStorage("userGender") var userGender = "Hombre"
    // Ruido preferido para la respiración.
    @AppStorage("userNoise") var userNoise = "Blanco"
    // Hora en la que el usuario tiene tiempo libre.
    @AppStorage("userFreeTime") var userFreeTime = Date()

    // Controla la animación de aparición del contenido.
    @State private var isVisible = false

    let genders = ["Hombre", "Mujer", "LGBTQ+"]
    let noises = ["Blanco", "Rosa", "Marrón", "Naturaleza", "Binaural"]

    // Construye la vista del formulario de bienvenida con animaciones.
    // Recoge los datos básicos del usuario y los guarda usando AppStorage.
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 24) {
                Text("Bienvenido a tu espacio")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.top, 40)
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : -20)
                    .animation(.easeOut(duration: 0.6), value: isVisible)

                Group {
                    TextField("Nombre", text: $userName)
                    TextField("Apellidos", text: $userLastName)

                    DatePicker("Fecha de nacimiento", selection: $userBirthDate, displayedComponents: .date)

                    Picker("Género", selection: $userGender) {
                        ForEach(genders, id: \.self) { gender in
                            Text(gender)
                        }
                    }

                    Picker("Tipo de ruido preferido", selection: $userNoise) {
                        ForEach(noises, id: \.self) { noise in
                            Text(noise)
                        }
                    }

                    DatePicker("¿A qué hora estás libre?", selection: $userFreeTime, displayedComponents: .hourAndMinute)
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .foregroundColor(.white)
                .cornerRadius(12)
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 20)
                .animation(.easeOut(duration: 0.4).delay(0.2), value: isVisible)

                Button("Continuar") {
                    hasCompletedOnboarding = true
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.2))
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal)
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 20)
                .animation(.easeOut(duration: 0.4).delay(0.4), value: isVisible)
            }
            .padding()
        }
        .onAppear {
            isVisible = true
        }
    }
}
