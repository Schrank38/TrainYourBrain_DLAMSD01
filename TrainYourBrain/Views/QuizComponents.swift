import SwiftUI

/// Fortschritt, Punktestand und aktuelle Serie.
struct QuizProgressHeader: View {
    let position: Int
    let total: Int
    let score: Int
    let streak: Int

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Frage \(position) von \(total)")
                    .font(.subheadline.monospacedDigit())
                Spacer()
                if streak >= 2 {
                    Label("\(streak)", systemImage: "flame.fill")
                        .foregroundStyle(.orange)
                        .accessibilityLabel("Serie: \(streak) richtig in Folge")
                }
                Label("\(score)", systemImage: "star.fill")
                    .foregroundStyle(.yellow)
                    .accessibilityLabel("Punkte: \(score)")
            }
            .font(.subheadline.bold())

            ProgressView(value: Double(position - 1), total: Double(max(total, 1)))
        }
    }
}

/// Karte mit Kategorie, Schwierigkeit und Fragetext.
struct QuestionCard: View {
    let item: QueuedQuestion

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(item.question.category.title, systemImage: item.question.category.symbolName)
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Spacer()
                Text(item.question.difficulty.title)
                    .font(.caption.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.tint.opacity(0.15), in: Capsule())
            }
            if item.isRetry {
                Label("Wiederholung", systemImage: "arrow.counterclockwise")
                    .font(.caption.bold())
                    .foregroundStyle(.orange)
            }
            Text(item.question.prompt)
                .font(.title3.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

/// Antwortknöpfe für Multiple-Choice-Fragen inkl. Farbauflösung nach der Antwort.
struct MultipleChoiceAnswerView: View {
    let options: [String]
    let correctIndex: Int
    let isRevealed: Bool
    let onSelect: (Int) -> Void

    @State private var selectedIndex: Int?

    var body: some View {
        VStack(spacing: 12) {
            ForEach(options.indices, id: \.self) { index in
                Button {
                    selectedIndex = index
                    onSelect(index)
                } label: {
                    HStack {
                        Text(options[index])
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        if let symbol = resultSymbol(for: index) {
                            Image(systemName: symbol)
                        }
                    }
                    .padding()
                    .contentShape(Rectangle())
                    .background(background(for: index), in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .disabled(isRevealed)
            }
        }
    }

    private func background(for index: Int) -> Color {
        guard isRevealed else { return Color.accentColor.opacity(0.12) }
        if index == correctIndex { return .green.opacity(0.3) }
        if index == selectedIndex { return .red.opacity(0.3) }
        return .secondary.opacity(0.08)
    }

    private func resultSymbol(for index: Int) -> String? {
        guard isRevealed else { return nil }
        if index == correctIndex { return "checkmark.circle.fill" }
        if index == selectedIndex { return "xmark.circle.fill" }
        return nil
    }
}

/// Freitexteingabe mit Tastatur-Fokus und Bestätigung per Return-Taste.
struct TextAnswerView: View {
    let isLocked: Bool
    let onSubmit: (String) -> Void

    @State private var input = ""
    @FocusState private var isFocused: Bool

    private var trimmedInput: String {
        input.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        VStack(spacing: 12) {
            TextField("Deine Antwort", text: $input)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .submitLabel(.done)
                .focused($isFocused)
                .disabled(isLocked)
                .onSubmit(submit)

            Button(action: submit) {
                Text("Antwort prüfen").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLocked || trimmedInput.isEmpty)
        }
        .onAppear { isFocused = true }
    }

    private func submit() {
        guard !isLocked, !trimmedInput.isEmpty else { return }
        isFocused = false
        onSubmit(input)
    }
}

/// Rückmeldung nach einer Antwort mit Erklärung und Weiter-Knopf.
struct FeedbackView: View {
    let feedback: AnswerFeedback
    let isLastQuestion: Bool
    let onContinue: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(
                feedback.isCorrect ? "Richtig! +\(feedback.awardedPoints) Punkte" : "Leider falsch",
                systemImage: feedback.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill"
            )
            .font(.headline)
            .foregroundStyle(feedback.isCorrect ? .green : .red)

            if !feedback.isCorrect {
                Text("Richtige Antwort: \(feedback.correctAnswer)")
                    .font(.subheadline.bold())
                if feedback.willBeRepeated {
                    Text("Diese Frage kommt später noch einmal.")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }

            Text(feedback.explanation)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button(action: onContinue) {
                Text(isLastQuestion ? "Auswertung anzeigen" : "Weiter")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}
