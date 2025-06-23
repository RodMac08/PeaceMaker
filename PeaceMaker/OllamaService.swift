//
//  OllamaService.swift
//  PeaceMaker
//
//  Created by Rodrigo Macias Ruiz on 15/06/25.
//

import Foundation
import SwiftUI

// Servicio que gestiona la comunicación con el modelo de lenguaje vía Together.ai.
// Maneja el historial de chat y envía peticiones HTTP al endpoint de completación.
class OllamaService: ObservableObject {
    // Nombre del usuario actual, usado para personalizar la conversación.
    @AppStorage("userName") var userName = ""
    // Historial del chat con roles y contenido, incluyendo un mensaje inicial del sistema.
    private lazy var chatHistory: [[String: String]] = [
        ["role": "system", "content": "Tu nombre es Seren. Estás ayudando a \(userName) con su bienestar emocional. Responde con empatía y usando su nombre."]
    ]
    // Envía un mensaje del usuario al modelo y procesa la respuesta del asistente.
    // Parametros:
    //   - prompt: El mensaje de entrada del usuario.
    //   - completion: Closure que devuelve la respuesta del modelo.
    func sendMessage(prompt: String, completion: @escaping (String) -> Void) {
        guard let url = URL(string: "https://api.together.xyz/v1/chat/completions") else { return }

        chatHistory.append(["role": "user", "content": prompt])

        let payload: [String: Any] = [
            "model": "mistralai/Mistral-7B-Instruct-v0.2",
            "messages": chatHistory,
            "temperature": 0.7,
            "max_tokens": 300
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer 06fd9dcf7ce9fb0778b360b2d9518dd6a20385bc021acdd45478898f8069d844", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let message = choices.first?["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                completion("No se pudo generar respuesta.")
                return
            }
            self.chatHistory.append(["role": "assistant", "content": content])
            DispatchQueue.main.async {
                completion(content.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }.resume()
    }
}
