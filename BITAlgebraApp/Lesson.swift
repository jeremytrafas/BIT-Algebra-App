import Foundation

struct Lesson {
    let title: String
    let steps: [LessonStep]
    let summary: String
}

struct LessonStep {
    let instruction: String
    let targetEquation: String?
}
