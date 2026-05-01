// Project: BIT Algebra
// Author: Jeremy Trafas
// Date: 2026-05-01

import SwiftUI
import VisionKit
import AVFoundation

// The main interactive session view for teaching algebra lessons and verifying physical tile inputs via OCR.
struct AlgebraLessonSessionView: View {
    // The curriculum data passed into the view.
    let curriculum: [AlgebraLesson]
    let lessonIndex: Int
    
    // Computes the current lesson based on the provided index.
    var lesson: AlgebraLesson { curriculum[lessonIndex] }
    
    // Persisted user preferences for haptics, equation spelling, and speech rate.
    @AppStorage("enableHaptics") private var enableHaptics: Bool = true
    @AppStorage("spellOutEquations") private var spellOutEquations: Bool = false
    @AppStorage("speechRate") private var speechRate: Double = 0.5
    
    // Accessibility focus states to guide VoiceOver naturally.
    @AccessibilityFocusState private var isHeaderFocused: Bool
    @AccessibilityFocusState private var isCheckScanFocused: Bool
    
    // Synthesizer used for custom text-to-speech audio feedback.
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    
    // Dynamic metrics for scaling UI elements based on user accessibility settings.
    @ScaledMetric private var checkmarkSize: CGFloat = 60
    @ScaledMetric private var equationTextSize: CGFloat = 24
    
    // State variables tracking the current phase, scanned text, and system feedback.
    @State private var currentPhase = "instruction"
    @State private var recognizedText: String = ""
    @State private var feedbackMessage: String = ""
    @State private var scannerRefreshID = UUID()
    
    // Extracts the first step of the lesson (POC currently uses 1 step per demo).
    var currentStep: AlgebraLessonStep { lesson.steps[0] }
    
    var body: some View {
        VStack {
            // Section: Header displaying the lesson title and mode flag.
            HStack {
                Text(lesson.title)
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
                Text("Trial Mode")
                    .font(.caption)
                    .bold()
                    .padding(6)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
            .accessibilityAddTraits(.isHeader)
            
            Divider()
            
            // Section: Main content area displaying instructions and target equations.
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // 1. Read normal instruction aloud.
                    Text(currentStep.instruction)
                        .font(.title2)
                        .fontWeight(.medium)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityFocused($isHeaderFocused)
                    
                    // 2. Display and read the target equation token-by-token if required.
                    if let target = currentStep.targetEquation {
                        if spellOutEquations {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 2) {
                                    let tokens = tokenizeEquation(target)
                                    ForEach(Array(tokens.enumerated()), id: \.offset) { index, token in
                                        Text(token)
                                            .font(.system(size: equationTextSize, weight: .bold, design: .monospaced))
                                            .foregroundColor(.purple)
                                            .accessibilityElement(children: .ignore)
                                            .accessibilityLabel(token)
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                        } else {
                            Text(target)
                                .font(.system(size: equationTextSize, weight: .bold, design: .monospaced))
                                .foregroundColor(.purple)
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Section: Action area handling the camera feed and phase transitions.
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
                    // Check if the physical hardware supports VisionKit scanning.
                    if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
                        ZStack(alignment: .bottom) {
                            
                            // CAMERA: Rotated 90 degrees CW to match the physical device stand.
                            CameraScannerBox(recognizedText: $recognizedText)
                                .id(scannerRefreshID)
                                .rotationEffect(.degrees(90))
                                .frame(height: 350)
                                .cornerRadius(15)
                                .clipped()
                            
                            // Debugging overlay showing the raw OCR feed.
                            VStack(spacing: 4) {
                                Text("RAW OCR FEED:")
                                    .font(.caption2)
                                    .bold()
                                ForEach(recognizedText.components(separatedBy: "\n").suffix(3), id: \.self) { line in
                                    Text(line)
                                        .font(.caption)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .padding(8)
                            .frame(maxWidth: .infinity)
                            .background(Color.black.opacity(0.85))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding(.bottom, 10)
                        }
                        .padding(.horizontal)
                        
                        // Button to trigger the verification sequence.
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
                        .accessibilityFocused($isCheckScanFocused)
                        .padding()
                        
                    } else {
                        // Fallback input box if running on an Xcode Simulator.
                        SimulatorInputBox(recognizedText: $recognizedText)
                        Button("Check Simulator") { verifyStep() }
                            .padding()
                    }
                }
                else if currentPhase == "success" {
                    // Display success state and reset option.
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: checkmarkSize))
                            .foregroundColor(.green)
                        
                        Text("Verification Passed")
                            .font(.headline)
                            .fixedSize(horizontal: false, vertical: true)
                        
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
            
            // Section: Dynamic text output for verification feedback.
            if !feedbackMessage.isEmpty {
                Text(feedbackMessage)
                    .font(.headline)
                    .foregroundColor(feedbackMessage.contains("Correct") ? Color(UIColor.systemGreen) : Color(UIColor.systemRed))
                    .padding()
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .onAppear {
            // Shifts VoiceOver focus to the header automatically on load.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isHeaderFocused = true
            }
        }
        .onDisappear {
            // Cut off any ongoing speech if the user leaves the view.
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
    }
    
    // MARK: - LOGIC
    
    // Transitions the view into the scanning phase and clears previous data.
    func startTest() {
        currentPhase = "scanning"
        feedbackMessage = ""
        recognizedText = ""
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            isCheckScanFocused = true
        }
    }
    
    // Resets the view back to the original instruction phase.
    func resetTrial() {
        currentPhase = "instruction"
        recognizedText = ""
        feedbackMessage = ""
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isHeaderFocused = true
        }
    }
    
    // Core engine logic: Evaluates if the scanned mathematical input matches the target output.
    func verifyStep() {
        guard let target = currentStep.targetEquation else { return }
        
        // 1. Break the target equation into an array of individual clean lines.
        let targetLines = target.lowercased()
            .replacingOccurrences(of: " ", with: "")
            .components(separatedBy: "\n")
            .filter { !$0.isEmpty }
            
        // 2. Clean the recognized text to create one unified, searchable string.
        let cleanRecognized = recognizedText.lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "\n", with: "")
            
        // 3. ORDER-INDEPENDENT CHECK: Verify every target line exists somewhere in the scanned text.
        var allLinesFound = true
        for line in targetLines {
            if !cleanRecognized.contains(line) {
                allLinesFound = false
                break
            }
        }
        
        // 4. Handle state based on whether the equations matched.
        if allLinesFound {
            feedbackMessage = "Correct!"
            currentPhase = "success"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.speak("Correct.")
            }
            triggerHaptic(success: true)
            
        } else {
            if recognizedText.isEmpty {
                feedbackMessage = "No text detected. Check if the camera is covered."
                speak(feedbackMessage)
            } else {
                // If incorrect, replace newlines with commas so VoiceOver reads the full block naturally.
                let formattedSpeech = recognizedText.replacingOccurrences(of: "\n", with: ", ")
                feedbackMessage = "Mismatch. Saw: \(formattedSpeech)"
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.speak("Mismatch. I saw: \(formattedSpeech)")
                }
            }
            triggerHaptic(success: false)
            
            // Refresh the camera feed on a failure.
            scannerRefreshID = UUID()
            recognizedText = ""
        }
    }
    
    // Processes strings through AVSpeechSynthesizer using the user's custom speed preference.
    func speak(_ text: String) {
        speechSynthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: text)
        
        utterance.rate = Float(speechRate)
        
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .voicePrompt)
        try? AVAudioSession.sharedInstance().setActive(true)
        speechSynthesizer.speak(utterance)
    }
    
    // Fires physical haptic vibrations if enabled by the user in Settings.
    func triggerHaptic(success: Bool) {
        if enableHaptics {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(success ? .success : .error)
        }
    }
    
    // Parses a continuous equation string into individual components so VoiceOver can read it smoothly.
    func tokenizeEquation(_ equation: String) -> [String] {
        var tokens: [String] = []
        var currentNumber = ""
        
        for char in equation {
            if char.isNumber {
                currentNumber.append(char)
            } else {
                if !currentNumber.isEmpty {
                    tokens.append(currentNumber)
                    currentNumber = ""
                }
                tokens.append(String(char))
            }
        }
        if !currentNumber.isEmpty {
            tokens.append(currentNumber)
        }
        return tokens
    }
}

// MARK: - HELPER VIEWS & SCANNER

// Fallback UI for simulator testing when the physical camera is unavailable.
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

// Simple wrapper view to inject the UIViewControllerRepresentable into SwiftUI.
struct CameraScannerBox: View {
    @Binding var recognizedText: String
    var body: some View {
        ScannerViewControllerRepresentable(recognizedText: $recognizedText)
    }
}

// Bridges Apple's UIKit DataScannerViewController into the SwiftUI environment.
struct ScannerViewControllerRepresentable: UIViewControllerRepresentable {
    @Binding var recognizedText: String
    
    // Initializes the VisionKit scanner with strict math-appropriate parameters.
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.text(languages: ["en-US"])],
            qualityLevel: .accurate, // Forces the heaviest, most accurate machine learning model
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
    
    // Handles the asynchronous stream of text recognized by the camera.
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        var parent: ScannerViewControllerRepresentable
        
        init(parent: ScannerViewControllerRepresentable) { self.parent = parent }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didUpdate updatedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            let textItems = allItems.compactMap { item -> (text: String, y: CGFloat)? in
                if case .text(let text) = item {
                    // Filters out visual noise to only allow mathematical characters
                    let allowedCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+-=().^/* \n"
                    let clean = text.transcript.filter { allowedCharacters.contains($0) }
                    return (clean, item.bounds.topLeft.y)
                }
                return nil
            }
            
            // Sorts the items top-to-bottom based on their Y-axis position in the camera view
            let sortedItems = textItems.sorted { $0.y < $1.y }
            let allText = sortedItems.map { $0.text }.joined(separator: "\n")
            
            // Pushes the final string back to the main thread
            DispatchQueue.main.async {
                self.parent.recognizedText = allText
            }
        }
    }
}
