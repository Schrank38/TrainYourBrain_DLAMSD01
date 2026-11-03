import SwiftUI

/// Auswertung am Ende einer Runde.
struct ResultView: View {
    let result: QuizResult
    let missedQuestions: [Question]
    let onRestart: () -> Void
    let onClose: () -> Void

    var body: some View {
        List {
            Section {
                VStack(spacing: 12) {
                    Image(systemName: result.trophySymbol)
                        .font(.system(size: 56))
                        .foregroundStyle(.yellow)
                        .accessibilityHidden(true)
                    Text("\(result.score) Punkte")
                        .font(.largeTitle.bold())
                    Text(result.ratingText)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
            }

            Section("Statistik") {
                LabeledContent("Beim ersten Versuch richtig",
                               value: "\(result.correctFirstTry) von \(result.totalQuestions)")
                LabeledContent("In der Wiederholung richtig", value: "\(result.correctOnRetry)")
                LabeledContent("Trefferquote") {
                    Text(result.accuracy, format: .percent.precision(.fractionLength(0)))
                }
                LabeledContent("Längste Serie", value: "\(result.bestStreak)")
            }

            if !missedQuestions.isEmpty {
                Section("Zum Nachlernen") {
                    ForEach(missedQuestions) { question in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(question.prompt).font(.subheadline.bold())
                            Text("Richtig: \(question.correctAnswerText)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section {
                Button(action: onRestart) {
                    Label("Nochmal spielen", systemImage: "arrow.clockwise")
                }
                Button(action: onClose) {
                    Label("Zur Startseite", systemImage: "house")
                }
            }
        }
    }
}
