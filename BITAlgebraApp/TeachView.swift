import SwiftUI

// MARK: - DATA MODELS
// Restoring these structs so the view knows what a 'Lesson' is.

struct Lesson: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let steps: [LessonStep]
    let summary: String
}

struct LessonStep: Identifiable, Equatable {
    let id = UUID()
    let instruction: String
    let targetEquation: String? // Optional: nil means "Reading Only" step
}

// MARK: - VIEW

struct TeachView: View {
    // THE ENGINEERING POC CURRICULUM
    // This replaces the old textbook lessons with your 5 technical verification tests.
    let pocDemonstrations = [
        Lesson(
            title: "Demo 1: Character Baseline",
            steps: [
                LessonStep(
                    instruction: "Objective: Verify detection of all digits.\nTarget: 0123456789",
                    targetEquation: "0123456789"
                )
            ],
            summary: "Baseline Character Test Complete"
        ),
        Lesson(
            title: "Demo 2: Single Line Simple",
            steps: [
                LessonStep(
                    instruction: "Test 1: Single Line Simple Equation.\nScan: 8 + 4 = 12",
                    targetEquation: "8+4=12"
                )
            ],
            summary: "Test 1 Complete"
        ),
        Lesson(
            title: "Demo 3: Single Line Complex",
            steps: [
                LessonStep(
                    instruction: "Test 2: Single Line Complex Equation.\nScan: (3 * 4) ^ 2 * x = 89",
                    targetEquation: "(3*4)^2*x=89"
                )
            ],
            summary: "Test 2 Complete"
        ),
        Lesson(
            title: "Demo 4: Multi-Line Simple",
            steps: [
                LessonStep(
                    instruction: "Test 3: Multiple Lines (Simple).\nScan the stack:\n1) 8 + 4 * 2 = 16\n2) 8 + 8 = 16\n3) 16 = 16",
                    targetEquation: "8+4*2=16" // Detecting the top equation validates the scan
                )
            ],
            summary: "Test 3 Complete"
        ),
        Lesson(
            title: "Demo 5: Multi-Line Complex",
            steps: [
                LessonStep(
                    instruction: "Test 4: Multiple Lines (Complex).\nScan the stack:\n1) (3 * 2) ^ 2 - 4(6 + 2)\n2) (6)^2 - 4(6 + 2)\n3) (6)^2 - 4(8)",
                    targetEquation: "(3*2)^2-4(6+2)" // Detecting the top, most complex equation validates the scan
                )
            ],
            summary: "Test 4 Complete"
        )
    ]

    var body: some View {
        NavigationView {
            List(0..<pocDemonstrations.count, id: \.self) { index in
                NavigationLink(destination: LessonSessionView(curriculum: pocDemonstrations, lessonIndex: index)) {
                    HStack {
                        // Using a "Beaker" icon to signify R&D/Testing mode
                        Image(systemName: "flask.fill")
                            .foregroundColor(.purple)
                            .font(.title2)
                        
                        VStack(alignment: .leading) {
                            Text(pocDemonstrations[index].title)
                                .font(.headline)
                            Text("Verification Trial")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("POC Verification")
        }
    }
}
