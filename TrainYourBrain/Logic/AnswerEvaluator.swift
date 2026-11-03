import Foundation

/// Prüft Antworten. Reine Logik ohne UI-Bezug – dadurch `Sendable`
/// und isoliert testbar.
struct AnswerEvaluator: Sendable {

    func isCorrect(_ answer: UserAnswer, for question: Question) -> Bool {
        switch (question.format, answer) {
        case let (.multipleChoice(_, correctIndex), .choice(selectedIndex)):
            return selectedIndex == correctIndex

        case let (.textInput(acceptedAnswers), .text(input)):
            let normalizedInput = normalize(input)
            guard !normalizedInput.isEmpty else { return false }
            return acceptedAnswers.contains { normalize($0) == normalizedInput }

        default:
            // Antworttyp passt nicht zum Frageformat.
            return false
        }
    }

    /// Vereinheitlicht Freitext: ignoriert Groß-/Kleinschreibung, Akzente
    /// (z. B. „München“ = „Munchen“), „ß“/„ss“ und überzählige Leerzeichen.
    func normalize(_ text: String) -> String {
        text
            .replacingOccurrences(of: "ß", with: "ss")
            .folding(options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive],
                     locale: Locale(identifier: "de_DE"))
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
    }
}

/// Punkteregeln an einer Stelle gebündelt (leicht anpassbar).
struct ScoringRules: Sendable {
    var streakBonusStep = 2
    var maxStreakBonus = 10

    /// - Parameters:
    ///   - currentStreak: Anzahl richtiger Antworten in Folge *vor* dieser Antwort.
    ///   - isRetry: Wiederholungsfragen geben die halbe Grundpunktzahl ohne Bonus.
    func points(for difficulty: Difficulty, currentStreak: Int, isRetry: Bool) -> Int {
        if isRetry { return difficulty.basePoints / 2 }
        let bonus = min(currentStreak * streakBonusStep, maxStreakBonus)
        return difficulty.basePoints + bonus
    }
}
