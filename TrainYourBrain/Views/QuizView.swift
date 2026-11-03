import SwiftUI

/// Hauptbildschirm einer Quizrunde. Verbindet Nutzeraktionen mit der
/// `QuizSession` und zeigt je nach Phase Frage, Feedback oder Ergebnis.
struct QuizView: View {
    @Environment(ScoreStore.self) private var scoreStore
    @Environment(\.dismiss) private var dismiss
    @State private var session: QuizSession

    init(configuration: QuizConfiguration) {
        _session = State(initialValue: QuizSession(configuration: configuration))
    }

    var body: some View {
        NavigationStack {
            Group {
                if let result = session.result {
                    ResultView(
                        result: result,
                        missedQuestions: session.missedQuestions,
                        onRestart: restart,
                        onClose: { dismiss() }
                    )
                } else if let item = session.currentItem {
                    questionScreen(for: item)
                }
            }
            .navigationTitle(session.configuration.categoryFilter.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Beenden") { dismiss() }
                }
            }
            // Haptisches Feedback bei richtig/falsch (iOS 17+).
            .sensoryFeedback(trigger: session.phase) { _, newPhase in
                guard case .feedback(let feedback) = newPhase else { return nil }
                return feedback.isCorrect ? .success : .error
            }
            // Ergebnis genau einmal speichern, sobald die Runde endet.
            .onChange(of: session.result) { _, newResult in
                if let newResult { scoreStore.record(newResult) }
            }
        }
    }

    // MARK: Teilansichten

    private func questionScreen(for item: QueuedQuestion) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                QuizProgressHeader(
                    position: session.currentIndex + 1,
                    total: session.queue.count,
                    score: session.score,
                    streak: session.streak
                )
                QuestionCard(item: item)
                answerArea(for: item)

                if case .feedback(let feedback) = session.phase {
                    FeedbackView(
                        feedback: feedback,
                        isLastQuestion: session.isOnLastQuestion,
                        onContinue: { withAnimation(.snappy) { session.advance() } }
                    )
                }
            }
            .padding()
        }
        .scrollDismissesKeyboard(.interactively)
        // Neue Identität je Frage setzt lokalen View-Zustand (z. B. Texteingabe) zurück.
        .id(item.id)
    }

    @ViewBuilder
    private func answerArea(for item: QueuedQuestion) -> some View {
        switch item.question.format {
        case let .multipleChoice(options, correctIndex):
            MultipleChoiceAnswerView(
                options: options,
                correctIndex: correctIndex,
                isRevealed: session.isShowingFeedback,
                onSelect: { index in submit(.choice(index)) }
            )
        case .textInput:
            TextAnswerView(
                isLocked: session.isShowingFeedback,
                onSubmit: { text in submit(.text(text)) }
            )
        }
    }

    // MARK: Aktionen

    private func submit(_ answer: UserAnswer) {
        withAnimation(.snappy) { session.submit(answer) }
    }

    private func restart() {
        session = QuizSession(configuration: session.configuration)
    }
}
