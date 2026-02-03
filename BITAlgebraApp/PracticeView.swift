import SwiftUI
import VisionKit

struct PracticeView: View {
    // SETTINGS (Haptics only)
    @AppStorage("enableHaptics") private var enableHaptics: Bool = true
    
    // STATE VARIABLES
    @State private var currentPhase = "input" // phases: input, solving, success
    @State private var recognizedText: String = ""
    @State private var feedbackMessage: String = ""
    
    // SOLVER VARIABLES
    @State private var steps: [EquationStep] = []
    @State private var currentStepIndex = 0
    @State private var showStep: Bool = false
    
    var body: some View {
        VStack {
            // HEADER
            Text("Practice Mode")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
                .padding()
            
            // PHASE 1: INPUT THE PROBLEM
            if currentPhase == "input" {
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Create Your Own Problem")
                            .font(.largeTitle)
                            .bold()
                        
                        Text("Use the tiles to build any linear equation (like 2x + 4 = 10). Then scan it.")
                            .font(.title2)
                            .padding()
                        
                        if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
                            CameraScannerBox(recognizedText: $recognizedText)
                                .frame(height: 300)
                        } else {
                            SimulatorInputBox(recognizedText: $recognizedText)
                        }
                        
                        if !feedbackMessage.isEmpty {
                            Text(feedbackMessage)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                                .padding()
                                .accessibilityLabel(feedbackMessage)
                        }
                        
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
            
            // PHASE 2: STEP-BY-STEP GUIDANCE
            else if currentPhase == "solving" {
                ScrollView {
                    VStack(spacing: 20) {
                        
                        Text("Step \(currentStepIndex + 1)")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.top)
                        
                        // --- THE REVEAL SECTION ---
                        if showStep {
                            // VISIBLE STATE
                            VStack(spacing: 20) {
                                // 1. The Instruction
                                Text(steps[currentStepIndex].instruction)
                                    .font(.title)
                                    .bold()
                                    .multilineTextAlignment(.center)
                                    .padding()
                                    .background(Color.yellow.opacity(0.2))
                                    .cornerRadius(15)
                                
                                // 2. The Answer
                                Text("Answer: " + steps[currentStepIndex].targetState)
                                    .font(.system(size: 30, weight: .heavy, design: .monospaced))
                                    .foregroundColor(.blue)
                                
                                // Hide Button
                                Button(action: {
                                    showStep = false
                                }) {
                                    Text("Hide Hint")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .padding(10)
                                }
                            }
                            .accessibilityElement(children: .combine)
                        } else {
                            // HIDDEN STATE
                            Button(action: {
                                showStep = true
                            }) {
                                VStack(spacing: 10) {
                                    Image(systemName: "eye.slash.fill")
                                        .font(.largeTitle)
                                    Text("Reveal Step & Answer")
                                        .font(.headline)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.black)
                                .cornerRadius(15)
                            }
                            .padding(.horizontal)
                            .accessibilityLabel("Reveal Next Step")
                            .accessibilityHint("Double tap to reveal the instruction and answer")
                        }
                        
                        // Input Area
                        if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
                            CameraScannerBox(recognizedText: $recognizedText)
                                .frame(height: 250)
                        } else {
                            SimulatorInputBox(recognizedText: $recognizedText)
                        }
                        
                        if !feedbackMessage.isEmpty {
                            Text(feedbackMessage)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(feedbackMessage.contains("Correct") ? .green : .red)
                                .padding()
                                .accessibilityLabel(feedbackMessage)
                        }
                        
                        Button(action: {
                            verifyStep()
                        }) {
                            Text("Check My Board")
                                .font(.title2)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                        }
                        .padding()
                    }
                }
            }
            
            // PHASE 3: SUCCESS
            else if currentPhase == "success" {
                VStack(spacing: 30) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.yellow)
                    
                    Text("Equation Solved!")
                        .font(.largeTitle)
                        .bold()
                    
                    Text("You found the value of X.")
                        .font(.title2)
                    
                    Button(action: {
                        resetPractice()
                    }) {
                        Text("Solve Another Problem")
                            .font(.title2)
                            .padding()
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(10)
                    }
                }
            }
        }
    }
    
    // MARK: - LOGIC FUNCTIONS
    
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
    
    func resetPractice() {
        currentPhase = "input"
        recognizedText = ""
        feedbackMessage = ""
        steps = []
        currentStepIndex = 0
        showStep = false
    }
    
    func triggerHaptic(success: Bool) {
        if enableHaptics {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(success ? .success : .error)
        }
    }
}

// MARK: - MATH ENGINE
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
        
        // Step 1: Add/Sub
        if b != 0 {
            if b > 0 {
                currentRHS -= b
                calculatedSteps.append(EquationStep(instruction: "Subtract \(b) from both sides", targetState: "\(a)x=\(currentRHS)"))
            } else {
                currentRHS -= b
                calculatedSteps.append(EquationStep(instruction: "Add \(abs(b)) to both sides", targetState: "\(a)x=\(currentRHS)"))
            }
        }
        
        // Step 2: Divide
        if a != 1 && a != 0 {
            let finalResult = currentRHS / a
            calculatedSteps.append(EquationStep(instruction: "Divide both sides by \(a)", targetState: "x=\(finalResult)"))
        }
        
        return calculatedSteps.isEmpty ? nil : calculatedSteps
    }
}
