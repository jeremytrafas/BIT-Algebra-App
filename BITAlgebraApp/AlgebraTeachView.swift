// Project: BIT Algebra
// Author: Jeremy Trafas
// Date: 2026-05-01

import SwiftUI

// Teaching/verification demos listing.
struct AlgebraTeachView: View {
    // Predefined curriculum demos with target equations.
    let pocDemonstrations = [
        AlgebraLesson(
            title: "Demo 1: Character Baseline",
            steps: [
                AlgebraLessonStep(
                    instruction: "Objective: Verify detection of all digits. Create the equation below:",
                    targetEquation: "0123456789"
                )
            ],
            summary: "Baseline Character Test Complete"
        ),
        AlgebraLesson(
            title: "Demo 2: Single Line Simple",
            steps: [
                AlgebraLessonStep(
                    instruction: "Test 1: Single Line Simple Equation. Create the equation below:",
                    targetEquation: "8+4=12"
                )
            ],
            summary: "Test 1 Complete"
        ),
        AlgebraLesson(
            title: "Demo 3: Single Line Complex",
            steps: [
                AlgebraLessonStep(
                    instruction: "Test 2: Single Line Complex Equation. Create the equation below:",
                    targetEquation: "(3*4)^2*x=89"
                )
            ],
            summary: "Test 2 Complete"
        ),
        AlgebraLesson(
            title: "Demo 4: Multi-Line Simple",
            steps: [
                AlgebraLessonStep(
                    instruction: "Test 3: Multiple Lines (Simple). Create the equation below:",
                    targetEquation: "8+4*2=16\n8+8=16\n16=16"
                )
            ],
            summary: "Test 3 Complete"
        ),
        AlgebraLesson(
            title: "Demo 5: Multi-Line Complex",
            steps: [
                AlgebraLessonStep(
                    instruction: "Test 4: Multiple Lines (Complex). Create the equation below:",
                    targetEquation: "(2^3)+8=16\n8+8=16\n16=16"
                )
            ],
            summary: "Test 4 Complete"
        ),
        AlgebraLesson(
            title: "Demo 6: Exponents Simple",
            steps: [
                AlgebraLessonStep(
                    instruction: "Test 5: Exponents Simple Equation. Create the equation below:",
                    targetEquation: "x^2=4"
                )
            ],
            summary: "Test 5 Complete"
        ),
        AlgebraLesson(
            title: "Demo 7: Sequential Equations",
            steps: [
                AlgebraLessonStep(
                    instruction: "Test 6: Sequential Equations. Create the equations below:",
                    targetEquation: "8+4=12\n1+2=3\nx+5=6"
                )
            ],
            summary: "Test 6 Complete"
        )
    ]

    // List of demos navigating to session view.
    var body: some View {
        List(0..<pocDemonstrations.count, id: \.self) { index in
            NavigationLink(destination: AlgebraLessonSessionView(curriculum: pocDemonstrations, lessonIndex: index)) {
                // Row with icon and titles for each demo.
                HStack {
                    Image(systemName: "flask.fill")
                        .foregroundColor(.purple)
                        .font(.title2)
                    
                    VStack(alignment: .leading) {
                        Text(pocDemonstrations[index].title)
                            .font(.headline)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text("Verification Trial")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.vertical, 8)
            }
        }
        // Navigation title for the demos list.
        .navigationTitle("POC Verification")
    }
}

