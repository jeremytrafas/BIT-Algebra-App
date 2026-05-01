import Foundation

struct AlgebraLesson {
    let title: String
    let steps: [AlgebraLessonStep]
    let summary: String
}

struct AlgebraLessonStep {
    let instruction: String
    let targetEquation: String?
}
