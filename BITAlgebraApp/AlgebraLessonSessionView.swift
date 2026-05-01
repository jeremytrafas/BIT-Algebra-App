import SwiftUI
import VisionKit
import AVFoundation

struct AlgebraLessonSessionView: View {
    // DATA PASSED IN
    let curriculum: [AlgebraLesson]
    let lessonIndex: Int
    
    var lesson: AlgebraLesson { curriculum[lessonIndex] }
    
    // SETTINGS
    @AppStorage("enableHaptics") private var enableHaptics: Bool = true
    @AppStorage("spellOutEquations") private var spellOutEquations: Bool = false
    
    // ACCESSIBILITY & AUDIO
    @AccessibilityFocusState private var isHeaderFocused: Bool
    @AccessibilityFocusState private var isCheckScanFocused: Bool
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    
    // DYNAMIC TYPE METRICS
    @ScaledMetric private var checkmarkSize: CGFloat = 60
    @ScaledMetric private var equationTextSize: CGFloat = 24
    
    // SESSION STATE
    @State private var currentPhase = "instruction" // phases: instruction, scanning, success
    @State private var recognizedText: String = ""
    @State private var feedbackMessage: String = ""
    @State private var scannerRefreshID = UUID()
    
    var currentStep: AlgebraLessonStep { lesson.steps[0] } // POC only has 1 step per demo
    
    var body: some View {
        VStack {
            // HEADER
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
            
            // MAIN CONTENT
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // 1. Read Normal Instruction
                    Text(currentStep.instruction)
                        .font(.title2)
                        .fontWeight(.medium)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityFocused($isHeaderFocused)
                    
                    // 2. Read Target Equation Token-by-Token
                    if let target = currentStep.targetEquation {
                        if spellOutEquations {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 2) {
                                    let tokens = tokenizeEquation(target) // <--- USE TOKENIZER HERE
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
                            
                            // CAMERA (Standard Orientation)
                            CameraScannerBox(recognizedText: $recognizedText)
                                .id(scannerRefreshID)
                                .frame(height: 350)
                                .cornerRadius(15)
                            
                            // Live Raw Feed for Debugging
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
                        .accessibilityFocused($isCheckScanFocused)
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
            
            // FEEDBACK MESSAGE
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            isCheckScanFocused = true
        }
    }
    
    func resetTrial() {
        currentPhase = "instruction"
        recognizedText = ""
        feedbackMessage = ""
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isHeaderFocused = true
        }
    }
    
    func verifyStep() {
        guard let target = currentStep.targetEquation else { return }
        
        let cleanTarget = target.lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "\n", with: "")
        
        let cleanRecognized = recognizedText.lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "\n", with: "")
        
        if cleanRecognized.contains(cleanTarget) {
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
                let studentLines = recognizedText.components(separatedBy: "\n")
                let lastLine = studentLines.last ?? ""
                feedbackMessage = "Mismatch. Saw: \(lastLine)"
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.speak("Mismatch. I saw: \(lastLine)")
                }
            }
            triggerHaptic(success: false)
            
            scannerRefreshID = UUID()
            recognizedText = ""
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
    
    // <--- NEW TOKENIZER FUNCTION --->
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
// [Keep SimulatorInputBox, CameraScannerBox, and ScannerViewControllerRepresentable exactly the same]
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
