import SwiftUI
import Speech
import AVFoundation

struct VoiceInputButton: View {
    @Binding var text: String
    @State private var isRecording = false
    @State private var recognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    @State private var audioEngine = AVAudioEngine()

    var body: some View {
        Button {
            isRecording ? stopRecording() : startRecording()
        } label: {
            Image(systemName: isRecording ? "waveform.circle.fill" : "mic.circle.fill")
                .font(.system(size: 26))
                .foregroundColor(isRecording ? Color(red: 0.1, green: 0.5, blue: 1.0) : Color.gray.opacity(0.5))
                .symbolEffect(.pulse, isActive: isRecording)
        }
    }

    private func startRecording() {
        SFSpeechRecognizer.requestAuthorization { status in
            guard status == .authorized else { return }
            DispatchQueue.main.async { self.beginRecording() }
        }
    }

    private func beginRecording() {
        stopRecording()
        let req = SFSpeechAudioBufferRecognitionRequest()
        req.shouldReportPartialResults = true
        recognitionRequest = req

        let node = audioEngine.inputNode
        let fmt = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: fmt) { buf, _ in req.append(buf) }

        audioEngine.prepare()
        try? audioEngine.start()

        recognitionTask = recognizer?.recognitionTask(with: req) { result, error in
            if let r = result { text = r.bestTranscription.formattedString }
            if error != nil || result?.isFinal == true { stopRecording() }
        }
        isRecording = true
    }

    private func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        isRecording = false
    }
}
