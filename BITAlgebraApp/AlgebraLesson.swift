// Project: BIT Algebra
// Author: Jeremy Trafas
// Date: 2026-05-01

import Foundation

// Represents a complete algebra lesson, including a title, a series of steps, and a concluding summary.
struct AlgebraLesson {
    let title: String
    let steps: [AlgebraLessonStep]
    let summary: String
}

// Represents a single step within an algebra lesson.
struct AlgebraLessonStep {
    // The instruction read to the user.
    let instruction: String
    // The expected equation the user needs to physically build.
    let targetEquation: String?
}
