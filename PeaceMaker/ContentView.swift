//
//  ContentView.swift
//  PeaceMaker
//
//  Created by Rodrigo Macias Ruiz on 15/06/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showSplash = true
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    @State private var messages: [String] = ["Hola, ¿cómo te sientes hoy?"]
    @State private var input: String = ""
    @StateObject private var ollama = OllamaService()
    @State private var isAppeared = false
    @State private var showBreathingView = false
    @State private var showSidebar = false
    @State private var showConfig = false
    @State private var showInfo = false

    /// Vista principal del chat, contiene el historial de mensajes y campo de entrada.
    /// Detecta palabras clave como "ansiedad" para redirigir a la vista de respiración.
    private var mainView: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(messages, id: \.self) { msg in
                        messageView(for: msg, isAppeared: isAppeared)
                    }
                }
                .padding()
            }

            HStack {
                TextField("Me siento...", text: $input)
                    .padding()
                    .background(.thickMaterial)
                    .foregroundColor(.white)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .cornerRadius(20)
                    .shadow(color: Color.black, radius: 3)

                Button("Enviar") {
                    withAnimation {
                        let userMessage = "Tú: \(input)"
                        messages.append(userMessage)
                        let lowercasedInput = input.lowercased()
                        if lowercasedInput.contains("ansiedad") || lowercasedInput.contains("acelerado") || lowercasedInput.contains("no puedo dormir") {
                            showBreathingView = true
                        }
                    }
                    ollama.sendMessage(prompt: input) { response in
                        withAnimation {
                            messages.append("Seren: \(response)")
                        }
                    }
                    input = ""
                }
                .padding()
                .background(Color.black.opacity(0.5))
                .foregroundColor(.white)
                .cornerRadius(20)
            }
            .padding()
            .opacity(isAppeared ? 1 : 0)
            .offset(y: isAppeared ? 0 : 40)
            .animation(.easeOut(duration: 0.5).delay(0.1), value: isAppeared)
        }
        .onTapGesture {
            hideKeyboard()
        }
        .backgroundFromUserDefaults()
    }

    /// Punto de entrada visual de la app.
    /// Muestra SplashScreen, Onboarding o la vista principal dependiendo del estado.
    /// Incluye lógica de navegación, barra lateral, y configuración de notificaciones.
    var body: some View {
        ZStack {
            if showSplash {
                SplashScreenView()
            } else {
                if !hasCompletedOnboarding {
                    OnboardingView()
                } else {
                    NavigationView {
                        ZStack {
                            mainView
                            if showSidebar {
                                HStack {
                                    VStack(alignment: .leading, spacing: 30) {
                                        Spacer()
                                        Button(action: {
                                            showConfig = true
                                        }) {
                                            HStack {
                                                Image(systemName: "gear")
                                                    .foregroundColor(.white)
                                                    .shadow(color: Color.white, radius: 2)
                                                Text("Configuración")
                                                    .foregroundColor(.white)
                                                    .shadow(color: Color.white, radius: 2)
                                            }
                                        }
                                        .padding(.top, 100)

                                        Button(action: {
                                            showInfo = true
                                        }) {
                                            HStack {
                                                Image(systemName: "info.square")
                                                    .foregroundColor(.white)
                                                    .shadow(color: Color.white, radius: 2)
                                                Text("Acerca de")
                                                    .foregroundColor(.white)
                                                    .shadow(color: Color.white, radius: 2)
                                            }
                                        }

                                        Spacer()
                                    }
                                    .padding()
                                    .frame(width: 250)
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(20)
                                    .transition(.move(edge: .leading))
                                    .ignoresSafeArea()
                                    Spacer()
                                }
                                .zIndex(1)
                            }
                        }
                        .animation(.easeInOut(duration: 0.3), value: showSidebar)
                        .navigationTitle("PeaceMaker")
                        .navigationBarTitleDisplayMode(.automatic)
                        .foregroundColor(Color.white)
                        .toolbar {
                            ToolbarItemGroup(placement: .navigationBarLeading) {
                                Button(action: {
                                    showSidebar.toggle()
                                }) {
                                    Image(systemName: "info.circle")
                                        .foregroundStyle(Color.white)
                                        .shadow(color: Color.white, radius: 3)
                                }
                            }

                            ToolbarItemGroup(placement: .navigationBarTrailing) {
                                Button("Respirar") {
                                    showBreathingView = true
                                }
                                .foregroundStyle(Color.white)
                                .shadow(color: Color.white, radius: 3)
                            }
                        }
                        .toolbarBackground(Color.black.opacity(0.1), for: .navigationBar)
                        .toolbarColorScheme(.dark, for: .navigationBar)
                        .onAppear {
                            withAnimation(.easeOut(duration: 1.0)) {
                                isAppeared = true
                            }
                            NotificationManager.shared.requestAuthorization()
                        }
                        .fullScreenCover(isPresented: $showBreathingView) {
                            BreathingView(onFinish: handleBreathingSessionEnd)
                                .transition(.move(edge: .bottom))
                                .animation(.easeInOut(duration: 0.4), value: showBreathingView)
                        }
                    }
                    .sheet(isPresented: $showConfig) {
                        ConfigView()
                    }
                    .sheet(isPresented: $showInfo) {
                        InfoView()
                    }
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    showSplash = false
                }
            }
        }
    }

    /// Añade un mensaje automático de Seren después de completar la sesión de respiración.
    private func handleBreathingSessionEnd() {
        withAnimation {
            messages.append("Seren: ¿Cómo te sientes ahora?")
        }
    }
}

#Preview {
    ContentView()
}

#if canImport(UIKit)
/// Oculta el teclado cuando el usuario toca fuera del campo de texto (solo en iOS).
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

/// Devuelve una vista estilizada para cada mensaje del chat.
/// Aplica formato distinto si el mensaje es del usuario o de Seren.
/// Incluye animaciones y sombras visuales.
@ViewBuilder
private func messageView(for msg: String, isAppeared: Bool) -> some View {
    let isUser = msg.hasPrefix("Tú:")
    let isCoach = msg.hasPrefix("Seren:")
    
    Text(msg)
        .padding()
        .background(
            Group {
                if isUser {
                    Color.white.opacity(0.3).background(.ultraThinMaterial)
                } else if isCoach {
                    Color.black.opacity(0.5).background(.ultraThinMaterial)
                } else {
                    Color.gray.opacity(0.1).background(.ultraThinMaterial)
                }
            }
        )
        .foregroundColor(isCoach ? .white : .primary)
        .cornerRadius(20)
        .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading) // Alinea según quien habla
        .shadow(color: isCoach ? .black : .white, radius: 3)
        .opacity(isAppeared ? 1 : 0)
        .offset(y: isAppeared ? 0 : 40)
        .animation(.easeOut(duration: 0.5).delay(0.1), value: isAppeared)
}
