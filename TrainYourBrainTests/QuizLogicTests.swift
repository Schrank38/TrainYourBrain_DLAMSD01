import Foundation
import Testing
@testable import TrainYourBrain

@Suite("AnswerEvaluator")
struct AnswerEvaluatorTests {
    private let evaluator = AnswerEvaluator()
    private let textQuestion = Question(
        category: .geography, difficulty: .easy,
        prompt: "Hauptstadt von Bayern?",
        format: .textInput(acceptedAnswers: ["München"]),
        explanation: ""
    )
    private let choiceQuestion = Question(
        category: .science, difficulty: .easy,
        prompt: "2 + 2?",
        format: .multipleChoice(options: ["3", "4"], correctIndex: 1),
        explanation: ""
    )

    @Test func textIgnoresCaseWhitespaceAndDiacritics() {
        #expect(evaluator.isCorrect(.text("  münchen "), for: textQuestion))
        #expect(evaluator.isCorrect(.text("MUNCHEN"), for: textQuestion))
    }

    @Test func textRejectsEmptyOrWrongInput() {
        #expect(!evaluator.isCorrect(.text("   "), for: textQuestion))
        #expect(!evaluator.isCorrect(.text("Berlin"), for: textQuestion))
    }

    @Test func multipleChoiceComparesIndex() {
        #expect(evaluator.isCorrect(.choice(1), for: choiceQuestion))
        #expect(!evaluator.isCorrect(.choice(0), for: choiceQuestion))
        #expect(!evaluator.isCorrect(.text("4"), for: choiceQuestion))
    }
}

@MainActor
@Suite("QuizSession")
struct QuizSessionTests {
    private let first = Question(category: .computing, difficulty: .easy, prompt: "Q1",
                                 format: .multipleChoice(options: ["a", "b"], correctIndex: 0),
                                 explanation: "")
    private let second = Question(category: .computing, difficulty: .easy, prompt: "Q2",
                                  format: .textInput(acceptedAnswers: ["ja"]),
                                  explanation: "")

    private func makeSession() -> QuizSession {
        QuizSession(
            configuration: QuizConfiguration(categoryFilter: .all, difficulty: .easy, questionCount: 2),
            questions: [first, second]
        )
    }

    @Test func correctAnswersBuildStreakBonus() {
        let session = makeSession()
        session.submit(.choice(0)); session.advance()   // 10 Punkte
        session.submit(.text("Ja")); session.advance()  // 10 + 2 Bonus
        #expect(session.phase == .finished)
        #expect(session.result?.score == 22)
        #expect(session.result?.bestStreak == 2)
    }

    @Test func wrongAnswerIsRepeatedOnceAtTheEnd() {
        let session = makeSession()
        session.submit(.choice(1))                      // falsch → Wiederholung
        #expect(session.queue.count == 3)
        session.advance()
        session.submit(.text("ja")); session.advance()  // 10 Punkte
        #expect(session.currentItem?.isRetry == true)
        session.submit(.choice(0)); session.advance()   // Wiederholung: 5 Punkte
        #expect(session.result?.score == 15)
        #expect(session.result?.correctFirstTry == 1)
        #expect(session.result?.correctOnRetry == 1)
        #expect(session.missedQuestions == [first])
    }

    @Test func scoreStorePersistsResults() throws {
        let suiteName = "TrainYourBrainTests-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = ScoreStore(defaults: defaults)
        store.record(QuizResult(categoryFilter: .all, difficulty: .hard, score: 90,
                                correctFirstTry: 3, correctOnRetry: 0,
                                totalQuestions: 3, bestStreak: 3))

        let reloaded = ScoreStore(defaults: defaults)
        #expect(reloaded.bestScore(for: .all, difficulty: .hard) == 90)
    }
}
