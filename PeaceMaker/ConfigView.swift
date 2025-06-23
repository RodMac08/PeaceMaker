//
//  ConfigView.swift
//  PeaceMaker
//
//  Created by Rodrigo Macias Ruiz on 20/06/25.
//

import SwiftUI
import PhotosUI

// Vista de configuración de usuario para ajustar sonido, tema, fondo y notificaciones.
struct ConfigView: View {
    // Preferencia del tipo de ruido seleccionado por el usuario.
    @AppStorage("userNoise") var userNoise = "Blanco"
    // Hora preferida para la notificación diaria.
    @AppStorage("userFreeTime") var userFreeTime = Date()
    // Tema seleccionado para la aplicación.
    @AppStorage("appTheme") var appTheme = "Automático"
    // Estado de activación de las notificaciones.
    @AppStorage("notificationsEnabled") var notificationsEnabled = true
    // Controla la presentación del selector de imágenes.
    @State private var showImagePicker = false
    // Foto seleccionada desde el selector de imágenes.
    @State private var selectedPhoto: PhotosPickerItem?
    // Imagen de fondo personalizada cargada y mostrada.
    @State private var backgroundImage: Image?
    // Controla la presentación de la alerta de notificaciones.
    @State private var showNotificationAlert = false

    let noises = ["Blanco", "Rosa", "Marrón", "Naturaleza", "Binaural"]
    let themes = ["Claro", "Oscuro", "Automático"]

    var body: some View {
        NavigationView {
            Form {
                // Sección para seleccionar el tipo de ruido de fondo.
                Section(header: Text("Preferencias de sonido")) {
                    Picker("Tipo de ruido", selection: $userNoise) {
                        ForEach(noises, id: \.self) { noise in
                            Text(noise)
                        }
                    }
                }

                // Sección para configurar la hora y activación de la notificación diaria.
                Section(header: Text("Notificación diaria")) {
                    DatePicker("Hora", selection: $userFreeTime, displayedComponents: .hourAndMinute)
                    Toggle("Activar notificaciones", isOn: Binding(
                        get: {
                            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                            }
                            return true
                        },
                        set: { newValue in
                            if newValue {
                                NotificationManager.shared.scheduleDailyNotification()
                            } else {
                                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily_checkin"])
                            }
                            showNotificationAlert = true
                        }
                    ))
                    .onChange(of: userFreeTime) { _ in
                        NotificationManager.shared.scheduleDailyNotification()
                    }
                }

                // Sección para seleccionar el tema visual de la aplicación.
                Section(header: Text("Tema de la app")) {
                    Picker("Tema", selection: $appTheme) {
                        ForEach(themes, id: \.self) { theme in
                            Text(theme)
                        }
                    }
                }

                // Sección para seleccionar o restaurar la imagen de fondo personalizada.
                Section(header: Text("Fondo personalizado")) {
                    PhotosPicker("Seleccionar imagen de fondo", selection: $selectedPhoto, matching: .images)
                        .onChange(of: selectedPhoto) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    backgroundImage = Image(uiImage: uiImage)
                                    saveImageToDefaults(uiImage)
                                }
                            }
                        }
                    Button("Restaurar fondo por defecto") {
                        UserDefaults.standard.removeObject(forKey: "backgroundImageData")
                        backgroundImage = nil
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Configuración")
            .sheet(isPresented: $showImagePicker) {
                // futuro selector de imagen (no implementado aún)
                Text("Selector de imagen de fondo (próximamente)")
            }
            .onAppear {
                loadImageFromDefaults()
            }
            .alert(isPresented: $showNotificationAlert) {
                Alert(
                    title: Text("Notificaciones"),
                    message: Text(notificationsEnabled ? "Notificación diaria activada." : "Notificaciones desactivadas."),
                    dismissButton: .default(Text("Aceptar"))
                )
            }
        }
    }
    
    // Guarda la imagen seleccionada en UserDefaults para uso futuro como fondo personalizado.
    func saveImageToDefaults(_ image: UIImage) {
        if let data = image.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(data, forKey: "backgroundImageData")
        }
    }

    // Carga la imagen de fondo personalizada guardada en UserDefaults si existe.
    func loadImageFromDefaults() {
        if let data = UserDefaults.standard.data(forKey: "backgroundImageData"),
           let uiImage = UIImage(data: data) {
            backgroundImage = Image(uiImage: uiImage)
        }
    }
}

// MARK: - Background image helpers

// Recupera la imagen de fondo personalizada guardada en UserDefaults, si existe.
func getSavedBackgroundImage() -> Image? {
    if let data = UserDefaults.standard.data(forKey: "backgroundImageData"),
       let uiImage = UIImage(data: data) {
        return Image(uiImage: uiImage)
    }
    return nil
}

extension View {
    // Aplica la imagen de fondo personalizada como fondo de la vista, si está disponible.
    func backgroundFromUserDefaults() -> some View {
        if let bg = getSavedBackgroundImage() {
            return AnyView(self.background(bg.resizable().scaledToFill().ignoresSafeArea()))
        } else {
            return AnyView(self)
        }
    }
}
