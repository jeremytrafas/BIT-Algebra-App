// Project: BIT Algebra
// Author: Jeremy Trafas
// Date: 2026-05-01

import SwiftUI
import VisionKit

// Practice mode for scanning and solving user-provided equations.
struct AlgebraPracticeView: View {
    // User preferences for haptics and equation spelling.
    @AppStorage("enableHaptics") private var enableHaptics: Bool = true
    @AppStorage("spellOutEquations") private var spellOutEquations: Bool = false
    
    // Dynamic type metrics for larger UI elements.
    @ScaledMetric private var equationTextSize: CGFloat = 30
    @ScaledMetric private var giantIconSize: CGFloat = 100
    
    // View state for phases, OCR text, and feedback.
    @State private var currentPhase = "input"
    @State private var recognizedText: String = ""
    @State private var feedbackMessage: String = ""
    
    // Linear solver state and reveal control.
    @State private var steps: [EquationStep] = []
    @State private var currentStepIndex = 0
    @State private var showStep: Bool = false
    
    var body: some View {
        VStack {
            // Header title for practice mode.
            Text("Practice Mode")
                .font(.headline)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
                .padding()
            
            // Phase 1: Input and scan the equation.
            if currentPhase == "input" {
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Create Your Own Problem")
                            .font(.largeTitle)
                            .bold()
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text("Use the tiles to build any linear equation (like 2x + 4 = 10). Then scan it.")
                            .font(.title2)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding()
                        
                        // Live camera or simulator input for OCR.
                        if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
                            CameraScannerBox(recognizedText: $recognizedText)
                                .frame(height: 300)
                                .cornerRadius(15)
                                .padding(.horizontal)
                        } else {
                            SimulatorInputBox(recognizedText: $recognizedText)
                        }
                        
                        if !feedbackMessage.isEmpty {
                            Text(feedbackMessage)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(Color(UIColor.systemRed))
                                .padding()
                                .fixedSize(horizontal: false, vertical: true)
                                .accessibilityLabel(feedbackMessage)
                        }
                        
                        // Begin processing the scanned equation.
                        Button(action: {
                            processInitialEquation()
                        }) {
                            Text("Start Solving")
                                .font(.title2)
                                .bold()
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                        }
                        .padding()
                        .accessibilityHint("Analyzes your equation")
                    }
                }
            }
            
            // Phase 2: Step-by-step solving with optional reveal.
            else if currentPhase == "solving" {
                ScrollView {
                    VStack(spacing: 20) {
                        
                        Text("Step \(currentStepIndex + 1)")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.top)
                        
                        // Toggle to reveal or hide the current step and target state.
                        if showStep {
                            VStack(spacing: 20) {
                                Text(steps[currentStepIndex].instruction)
                                    .font(.title)
                                    .bold()
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding()
                                    .background(Color.yellow.opacity(0.2))
                                    .cornerRadius(15)
                                
                                Text("Answer:")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                    .accessibilityAddTraits(.isHeader)
                                
                                if spellOutEquations {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 2) {
                                            let tokens = tokenizeEquation(steps[currentStepIndex].targetState)
                                            ForEach(Array(tokens.enumerated()), id: \.offset) { index, token in
                                                Text(token)
                                                    .font(.system(size: equationTextSize, weight: .heavy, design: .monospaced))
                                                    .foregroundColor(.blue)
                                                    .accessibilityElement(children: .ignore)
                                                    .accessibilityLabel(token)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                } else {
                                    Text(steps[currentStepIndex].targetState)
                                        .font(.system(size: equationTextSize, weight: .heavy, design: .monospaced))
                                        .foregroundColor(.blue)
                                }
                                
                                Button(action: {
                                    showStep = false
                                }) {
                                    Text("Hide Hint")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .padding(10)
                                }
                            }
                            
                        } else {
                            Button(action: {
                                showStep = true
                            }) {
                                VStack(spacing: 10) {
                                    Image(systemName: "eye.slash.fill")
                                        .font(.largeTitle)
                                    Text("Reveal Step & Answer")
                                        .font(.headline)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.black)
                                .cornerRadius(15)
                            }
                            .padding(.horizontal)
                            .accessibilityLabel("Reveal Next Step")
                            .accessibilityHint("Press confirm to reveal the instruction and answer")
                        }
                        
                        // Scan the board to check current step.
                        if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
                            CameraScannerBox(recognizedText: $recognizedText)
                                .frame(height: 250)
                                .cornerRadius(15)
                                .padding(.horizontal)
                        } else {
                            SimulatorInputBox(recognizedText: $recognizedText)
                        }
                        
                        if !feedbackMessage.isEmpty {
                            Text(feedbackMessage)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(feedbackMessage.contains("Correct") ? Color(UIColor.systemGreen) : Color(UIColor.systemRed))
                                .padding()
                                .fixedSize(horizontal: false, vertical: true)
                                .accessibilityLabel(feedbackMessage)
                        }
                        
                        // Verify the scanned equation matches the target state.
                        Button(action: {
                            verifyStep()
                        }) {
                            Text("Check My Board")
                                .font(.title2)
                                .bold()
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .foregroundColor(.black)
                                .cornerRadius(15)
                        }
                        .padding()
                    }
                }
            }
            
            // Phase 3: Success confirmation and restart.
            else if currentPhase == "success" {
                VStack(spacing: 30) {
                    Image(systemName: "star.fill")
                        .font(.system(size: giantIconSize))
                        .foregroundColor(.yellow)
                    
                    Text("Equation Solved!")
                        .font(.largeTitle)
                        .bold()
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("You found the value of X.")
                        .font(.title2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Button(action: {
                        resetPractice()
                    }) {
                        Text("Solve Another Problem")
                            .font(.title2)
                            .bold()
                            .padding()
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    }
                }
            }
        }
    }
    
    // Parse scanned text and prepare solving steps.
    func processInitialEquation() {
        let clean = recognizedText.lowercased().replacingOccurrences(of: " ", with: "")
        
        if let calculatedSteps = LinearEquationSolver.solve(equation: clean) {
            steps = calculatedSteps
            currentStepIndex = 0
            feedbackMessage = ""
            showStep = false
            currentPhase = "solving"
        } else {
            feedbackMessage = "I couldn't understand that. I saw: \(recognizedText)"
            triggerHaptic(success: false)
        }
    }
    
    // Compare OCR input with expected target state.
    func verifyStep() {
        let cleanInput = recognizedText.lowercased().replacingOccurrences(of: " ", with: "")
        let cleanTarget = steps[currentStepIndex].targetState.lowercased().replacingOccurrences(of: " ", with: "")
        
        if cleanInput == cleanTarget {
            feedbackMessage = "Correct!"
            triggerHaptic(success: true)
            
            if currentStepIndex < steps.count - 1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    currentStepIndex += 1
                    feedbackMessage = ""
                    showStep = false
                }
            } else {
                currentPhase = "success"
                triggerHaptic(success: true)
            }
        } else {
            feedbackMessage = "Not quite. I see: \(recognizedText)"
            triggerHaptic(success: false)
        }
    }
    
    // Reset practice session to initial state.
    func resetPractice() {
        currentPhase = "input"
        recognizedText = ""
        feedbackMessage = ""
        steps = []
        currentStepIndex = 0
        showStep = false
    }
    
    // Provide haptic feedback based on result.
    func triggerHaptic(success: Bool) {
        if enableHaptics {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(success ? .success : .error)
        }
    }
    
    // Split equation into tokens for accessible reading.
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

// Lightweight linear equation solver for simple ax+b=c forms.
struct EquationStep {
    let instruction: String
    let targetState: String
}

struct LinearEquationSolver {
    static func solve(equation: String) -> [EquationStep]? {
        let components = equation.components(separatedBy: "=")
        guard components.count == 2 else { return nil }
        
        let leftSide = components[0]
        let rightSide = components[1]
        
        guard let c = Int(rightSide) else { return nil }
        guard let xIndex = leftSide.firstIndex(of: "x") else { return nil }
        
        let aString = String(leftSide[..<xIndex])
        let a = aString.isEmpty ? 1 : (Int(aString) ?? 1)
        
        let remainder = String(leftSide[leftSide.index(after: xIndex)...])
        var b = 0
        if !remainder.isEmpty {
            b = Int(remainder) ?? 0
        }
        
        var calculatedSteps: [EquationStep] = []
        var currentRHS = c
        
        if b != 0 {
            if b > 0 {
                currentRHS -= b
                calculatedSteps.append(EquationStep(instruction: "Subtract \(b) from both sides", targetState: "\(a)x=\(currentRHS)"))
            } else {
                currentRHS -= b
                calculatedSteps.append(EquationStep(instruction: "Add \(abs(b)) to both sides", targetState: "\(a)x=\(currentRHS)"))
            }
        }
        
        if a != 1 && a != 0 {
            let finalResult = currentRHS / a
            calculatedSteps.append(EquationStep(instruction: "Divide both sides by \(a)", targetState: "x=\(finalResult)"))
        }
        
        return calculatedSteps.isEmpty ? nil : calculatedSteps
    }
}
