import Foundation
import Observation

/// Eine Frage in der Warteschlange. `isRetry` markiert Wiederholungen.
struct QueuedQuestion: Identifiable, Equatable, Sendable {
    let id = UUID()
    let question: Question
    let isRetry: Bool
}

/// Rückmeldung nach einer Antwort.
struct AnswerFeedback: Equatable, Sendable {
    let isCorrect: Bool
    let awardedPoints: Int
    let correctAnswer: String
    let explanation: String
    let willBeRepeated: Bool
}

/// Zustände des Quiz-Ablaufs (einfacher Zustandsautomat).
enum QuizPhase: Equatable, Sendable {
    case answering
    case feedback(AnswerFeedback)
    case finished
}

/// Steuert eine Quizrunde. `@MainActor`, weil der Zustand direkt die
/// SwiftUI-Oberfläche treibt; `@Observable`, damit Views gezielt nur bei
/// Änderung der gelesenen Eigenschaften neu gezeichnet werden.
@MainActor
@Observable
final class QuizSession {

    // MARK: Öffentlicher Zustand (nur lesbar)

    let configuration: QuizConfiguration
    private(set) var queue: [QueuedQuestion]
    private(set) var currentIndex = 0
    private(set) var phase: QuizPhase = .answering
    private(set) var score = 0
    private(set) var streak = 0
    private(set) var bestStreak = 0
    private(set) var correctFirstTry = 0
    private(set) var correctOnRetry = 0
    /// Fragen, die beim ersten Versuch falsch beantwortet wurden.
    private(set) var missedQuestions: [Question] = []
    /// Wird beim Abschluss der Runde gesetzt.
    private(set) var result: QuizResult?

    /// Anzahl der ursprünglichen Fragen (ohne Wiederholungen).
    let originalQuestionCount: Int

    // MARK: Abhängigkeiten

    private let evaluator: AnswerEvaluator
    private let scoring: ScoringRules

    // MARK: Initialisierung

    /// - Parameter questions: Optional fest vorgegebene Fragen (z. B. für Tests);
    ///   sonst wird aus dem `QuestionBank`-Katalog gezogen.
    init(configuration: QuizConfiguration,
         questions: [Question]? = nil,
         evaluator: AnswerEvaluator = AnswerEvaluator(),
         scoring: ScoringRules = ScoringRules()) {
        let selected = questions ?? QuestionBank.questions(for: configuration)
        self.configuration = configuration
        self.queue = selected.map { QueuedQuestion(question: $0, isRetry: false) }
        self.originalQuestionCount = selected.count
        self.evaluator = evaluator
        self.scoring = scoring
        if queue.isEmpty { finish() }
    }

    // MARK: Abgeleitete Werte

    var currentItem: QueuedQuestion? {
        queue.indices.contains(currentIndex) ? queue[currentIndex] : nil
    }

    var isShowingFeedback: Bool {
        guard case .feedback = phase else { return false }
        return true
    }

    var isOnLastQuestion: Bool { currentIndex == queue.count - 1 }

    // MARK: Aktionen

    /// Wertet eine Antwort aus und wechselt in die Feedback-Phase.
    func submit(_ answer: UserAnswer) {
        guard phase == .answering, let item = currentItem else { return }

        let isCorrect = evaluator.isCorrect(answer, for: item.question)
        var awardedPoints = 0
        var willBeRepeated = false

        if isCorrect {
            awardedPoints = scoring.points(for: item.question.difficulty,
                                           currentStreak: streak,
                                           isRetry: item.isRetry)
            score += awardedPoints
            streak += 1
            bestStreak = max(bestStreak, streak)
            if item.isRetry { correctOnRetry += 1 } else { correctFirstTry += 1 }
        } else {
            streak = 0
            // Erstmals falsch beantwortete Fragen werden genau einmal am Ende wiederholt.
            if !item.isRetry {
                missedQuestions.append(item.question)
                queue.append(QueuedQuestion(question: item.question, isRetry: true))
                willBeRepeated = true
            }
        }

        phase = .feedback(AnswerFeedback(
            isCorrect: isCorrect,
            awardedPoints: awardedPoints,
            correctAnswer: item.question.correctAnswerText,
            explanation: item.question.explanation,
            willBeRepeated: willBeRepeated
        ))
    }

    /// Geht zur nächsten Frage oder beendet die Runde.
    func advance() {
        guard isShowingFeedback else { return }
        currentIndex += 1
        if currentIndex < queue.count {
            phase = .answering
        } else {
            finish()
        }
    }

    // MARK: Privat

    private func finish() {
        phase = .finished
        result = QuizResult(
            categoryFilter: configuration.categoryFilter,
            difficulty: configuration.difficulty,
            score: score,
            correctFirstTry: correctFirstTry,
            correctOnRetry: correctOnRetry,
            totalQuestions: originalQuestionCount,
            bestStreak: bestStreak
        )
    }
}
