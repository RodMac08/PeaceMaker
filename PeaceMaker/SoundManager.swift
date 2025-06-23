//
//  SoundManager.swift
//  PeaceMaker
//
//  Created by Rodrigo Macias Ruiz on 15/06/25.
//

import AVFoundation

// Clase singleton para manejar la reproducción de sonidos ambientales.
// Soporta reproducción continua con entrada/salida de volumen suavizada.
class SoundManager {
    // Instancia compartida del manejador de sonido.
    static let shared = SoundManager()
    // Reproductor de audio para reproducir sonidos configurados.
    var player: AVAudioPlayer?

    // Inicia la reproducción de un sonido ambiental según el tipo especificado.
    // Aplica un efecto de entrada gradual (fade in).
    // - Parameter noiseType: Tipo de ruido a reproducir (ej. "blanco", "rosa", etc.).
    func play(noiseType: String) {
        let fileName: String

        switch noiseType.lowercased() {
        case "blanco":
            fileName = "white_noise"
        case "rosa":
            fileName = "pink_noise"
        case "marrón":
            fileName = "brown_noise"
        case "naturaleza":
            fileName = "nature_sounds"
        case "binaural":
            fileName = "binaural_beats"
        default:
            fileName = "white_noise"
        }

        if let path = Bundle.main.path(forResource: fileName, ofType: "mp3") {
            let url = URL(fileURLWithPath: path)
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.numberOfLoops = -1
                player?.volume = 0
                player?.play()

                // Fade in del sonido
                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                    if let player = self.player {
                        if player.volume < 1.0 {
                            player.volume += 0.05
                        } else {
                            player.volume = 1.0
                            timer.invalidate()
                        }
                    }
                }

            } catch {
                print("Error al reproducir sonido: \(error)")
            }
        }
    }

    // Detiene la reproducción de sonido con un efecto de salida gradual (fade out).
    func stop() {
        guard let player = player else { return }

        // Fade out del sonido
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if player.volume > 0.05 {
                player.volume -= 0.05
            } else {
                player.stop()
                timer.invalidate()
            }
        }
    }
}
