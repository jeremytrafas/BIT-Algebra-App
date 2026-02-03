import SwiftUI
import VisionKit
import AVFoundation

struct LessonSessionView: View {
    // DATA PASSED IN
    let curriculum: [Lesson]
    let lessonIndex: Int
    
    var lesson: Lesson { curriculum[lessonIndex] }
    
    // SETTINGS
    @AppStorage("enableHaptics") private var enableHaptics: Bool = true
    
    // ACCESSIBILITY & AUDIO
    @AccessibilityFocusState private var isHeaderFocused: Bool
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    
    // SESSION STATE
    @State private var currentPhase = "instruction" // phases: instruction, scanning, success
    @State private var recognizedText: String = ""
    @State private var feedbackMessage: String = ""
    
    var currentStep: LessonStep { lesson.steps[0] } // POC only has 1 step per demo
    
    var body: some View {
        VStack {
            // HEADER
            HStack {
                Text(lesson.title)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                // Removed Timer Display
                Text("Trial Mode")
                    .font(.caption)
                    .padding(6)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .foregroundColor(.gray)
            }
            .padding()
            .accessibilityAddTraits(.isHeader)
            
            Divider()
            
            // MAIN CONTENT
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(currentStep.instruction)
                        .font(.title2)
                        .fontWeight(.medium)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                        .accessibilityFocused($isHeaderFocused)
                }
            }
            
            // ACTION AREA
            VStack {
                if currentPhase == "instruction" {
                    Button(action: {
                        startTest()
                    }) {
                        Text("Start Test Trial")
                            .font(.title2)
                            .bold()
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                    .padding()
                }
                else if currentPhase == "scanning" {
                    if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
                        ZStack(alignment: .bottom) {
                            CameraScannerBox(recognizedText: $recognizedText)
                                .frame(height: 350)
                                .cornerRadius(15)
                            
                            // Live Raw Feed for Debugging
                            VStack(spacing: 4) {
                                Text("RAW OCR FEED:")
                                    .font(.caption2)
                                    .bold()
                                ForEach(recognizedText.components(separatedBy: "\n").suffix(2), id: \.self) { line in
                                    Text(line)
                                        .font(.caption)
                                        .lineLimit(1)
                                }
                            }
                            .padding(8)
                            .frame(maxWidth: .infinity)
                            .background(Color.black.opacity(0.6))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding(.bottom, 10)
                        }
                        .padding(.horizontal)
                        
                        // Check Button
                        Button(action: {
                            verifyStep()
                        }) {
                            Text("Check Scan")
                                .font(.title2)
                                .bold()
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                        }
                        .padding()
                        
                    } else {
                        SimulatorInputBox(recognizedText: $recognizedText)
                        Button("Check Simulator") { verifyStep() }
                            .padding()
                    }
                }
                else if currentPhase == "success" {
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Verification Passed")
                            .font(.headline)
                        
                        Button(action: {
                            resetTrial()
                        }) {
                            Text("Reset for Next Trial")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.black)
                                .cornerRadius(15)
                        }
                    }
                    .padding()
                }
            }
            
            // FEEDBACK MESSAGE
            if !feedbackMessage.isEmpty {
                Text(feedbackMessage)
                    .font(.headline)
                    .foregroundColor(feedbackMessage.contains("Correct") ? .green : .red)
                    .padding()
                    .multilineTextAlignment(.center)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isHeaderFocused = true
            }
        }
        .onDisappear {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
    }
    
    // MARK: - LOGIC
    
    func startTest() {
        currentPhase = "scanning"
        feedbackMessage = ""
        recognizedText = ""
    }
    
    func resetTrial() {
        currentPhase = "instruction"
        recognizedText = ""
        feedbackMessage = ""
        
        // Force VoiceOver focus back to instructions
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isHeaderFocused = true
        }
    }
    
    func verifyStep() {
        guard let target = currentStep.targetEquation else { return }
        
        let studentLines = recognizedText.components(separatedBy: "\n")
        let cleanTarget = target.lowercased().replacingOccurrences(of: " ", with: "")
        
        var foundMatch = false
        
        for line in studentLines {
            let cleanLine = line.lowercased().replacingOccurrences(of: " ", with: "")
            if cleanLine == cleanTarget {
                foundMatch = true
                break
            }
        }
        
        if foundMatch {
            feedbackMessage = "Correct!"
            currentPhase = "success"
            
            // Audio Feedback
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.speak("Correct.")
            }
            triggerHaptic(success: true)
            
        } else {
            // FAILED ATTEMPT
            if recognizedText.isEmpty {
                feedbackMessage = "No text detected."
                speak("No text detected.")
            } else {
                let lastLine = studentLines.last ?? ""
                feedbackMessage = "Mismatch. Saw: \(lastLine)"
                speak("Mismatch. I saw: \(lastLine)")
            }
            triggerHaptic(success: false)
        }
    }
    
    func speak(_ text: String) {
        speechSynthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.5
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .voicePrompt)
        try? AVAudioSession.sharedInstance().setActive(true)
        speechSynthesizer.speak(utterance)
    }
    
    func triggerHaptic(success: Bool) {
        if enableHaptics {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(success ? .success : .error)
        }
    }
}

// MARK: - HELPER VIEWS & SCANNER

struct SimulatorInputBox: View {
    @Binding var recognizedText: String
    var body: some View {
        VStack {
            Image(systemName: "camera.badge.slash").font(.largeTitle)
            Text("Simulator Mode")
            TextField("Type equation", text: $recognizedText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
        }
    }
}

struct CameraScannerBox: View {
    @Binding var recognizedText: String
    var body: some View {
        ScannerViewControllerRepresentable(recognizedText: $recognizedText)
    }
}

struct ScannerViewControllerRepresentable: UIViewControllerRepresentable {
    @Binding var recognizedText: String
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.text(languages: ["en-US"])],
            qualityLevel: .accurate,
            recognizesMultipleItems: true,
            isHighFrameRateTrackingEnabled: true,
            isGuidanceEnabled: false,
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        try? scanner.startScanning()
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        var parent: ScannerViewControllerRepresentable
        
        init(parent: ScannerViewControllerRepresentable) { self.parent = parent }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didUpdate updatedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            let textItems = allItems.compactMap { item -> (text: String, y: CGFloat)? in
                if case .text(let text) = item {
                    let allowedCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+-=().^/* \n"
                    let clean = text.transcript.filter { allowedCharacters.contains($0) }
                    return (clean, item.bounds.topLeft.y)
                }
                return nil
            }
            
            let sortedItems = textItems.sorted { $0.y < $1.y }
            let allText = sortedItems.map { $0.text }.joined(separator: "\n")
            
            DispatchQueue.main.async {
                self.parent.recognizedText = allText
            }
        }
    }
}
