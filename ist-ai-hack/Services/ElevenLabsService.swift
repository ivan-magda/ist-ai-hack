//
//  ElevenLabsService.swift
//  ist-ai-hack
//
//  Created by Ivan Magda on 5/28/25.
//

import Foundation
import AVFoundation

struct ElevenLabsRequest: Codable {
    let text: String
    let model_id: String
    let voice_settings: VoiceSettings

    struct VoiceSettings: Codable {
        let stability: Double
        let similarity_boost: Double
    }
}

@Observable
class ElevenLabsService: NSObject {
    private let session = URLSession.shared
    private var audioPlayer: AVAudioPlayer?

    var isPlaying = false
    var errorMessage: String?

    func synthesizeAndPlay(text: String) async -> Bool {
        guard APIKeyManager.shared.isElevenLabsConfigured() else {
            await MainActor.run {
                errorMessage = "Eleven Labs API key not configured"
            }
            return false
        }

        let voiceId = APIKeyManager.shared.elevenLabsVoiceId
        guard let url = URL(string: "https://api.elevenlabs.io/v1/text-to-speech/\(voiceId)") else {
            await MainActor.run {
                errorMessage = "Invalid Eleven Labs URL"
            }
            return false
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("audio/mpeg", forHTTPHeaderField: "Accept")
        request.setValue(APIKeyManager.shared.elevenLabsAPIKey, forHTTPHeaderField: "xi-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody = ElevenLabsRequest(
            text: text,
            model_id: "eleven_multilingual_v2",
            voice_settings: ElevenLabsRequest.VoiceSettings(
                stability: 0.6,
                similarity_boost: 0.75
            )
        )

        do {
            request.httpBody = try JSONEncoder().encode(requestBody)

            let (data, response) = try await session.data(for: request)

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                await MainActor.run {
                    errorMessage = "Eleven Labs API Error: Status code \(httpResponse.statusCode)"
                }
                return false
            }

            return await playAudio(data: data)
        } catch {
            await MainActor.run {
                errorMessage = "Network error: \(error.localizedDescription)"
            }
            return false
        }
    }

    @MainActor
    private func playAudio(data: Data) async -> Bool {
        do {
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()

            isPlaying = true
            errorMessage = nil
            audioPlayer?.play()

            return true
        } catch {
            errorMessage = "Audio playback error: \(error.localizedDescription)"
            return false
        }
    }

    func stopAudio() {
        audioPlayer?.stop()
        isPlaying = false
    }
}

extension ElevenLabsService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            isPlaying = false
        }
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        Task { @MainActor in
            isPlaying = false
            errorMessage = "Audio decode error: \(error?.localizedDescription ?? "Unknown error")"
        }
    }
}
