import Foundation

// MARK: - Kategorie

/// Themengebiet einer Frage.
enum QuizCategory: String, CaseIterable, Identifiable, Codable, Sendable {
    case geography
    case science
    case computing

    var id: String { rawValue }

    var title: String {
        switch self {
        case .geography: "Geografie"
        case .science: "Naturwissenschaft"
        case .computing: "Informatik"
        }
    }

    /// Name eines SF Symbols für die Darstellung.
    var symbolName: String {
        switch self {
        case .geography: "globe.europe.africa"
        case .science: "atom"
        case .computing: "cpu"
        }
    }
}

/// Auswahl im Startbildschirm: alle Kategorien gemischt oder genau eine.
enum CategoryFilter: Hashable, Codable, Sendable, Identifiable {
    case all
    case only(QuizCategory)

    /// Alle wählbaren Optionen in Anzeigereihenfolge.
    static var allOptions: [CategoryFilter] {
        [.all] + QuizCategory.allCases.map { .only($0) }
    }

    var id: String {
        switch self {
        case .all: "all"
        case .only(let category): category.rawValue
        }
    }

    var title: String {
        switch self {
        case .all: "Gemischt"
        case .only(let category): category.title
        }
    }

    var symbolName: String {
        switch self {
        case .all: "shuffle"
        case .only(let category): category.symbolName
        }
    }

    /// Prüft, ob eine Frage dieser Kategorie zum Filter passt.
    func includes(_ category: QuizCategory) -> Bool {
        switch self {
        case .all: true
        case .only(let selected): selected == category
        }
    }
}

// MARK: - Schwierigkeit

/// Schwierigkeitsstufe; der Rohwert dient zugleich als Punktefaktor.
enum Difficulty: Int, CaseIterable, Identifiable, Codable, Sendable {
    case easy = 1
    case medium = 2
    case hard = 3

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .easy: "Leicht"
        case .medium: "Mittel"
        case .hard: "Schwer"
        }
    }

    var hint: String {
        switch self {
        case .easy: "Grundlagenfragen – ideal zum Einstieg. 10 Punkte pro Frage."
        case .medium: "Etwas kniffliger. 20 Punkte pro Frage."
        case .hard: "Für Profis. 30 Punkte pro Frage."
        }
    }

    /// Grundpunktzahl für eine richtige Antwort.
    var basePoints: Int { rawValue * 10 }
}

// MARK: - Frage

/// Antwortformat einer Frage. Ein Enum mit assoziierten Werten stellt sicher,
/// dass jede Frage genau die Daten besitzt, die ihr Format benötigt.
enum AnswerFormat: Codable, Sendable, Hashable {
    /// Auswahl aus mehreren Optionen; `correctIndex` zeigt auf die richtige.
    case multipleChoice(options: [String], correctIndex: Int)
    /// Freitexteingabe; jede der akzeptierten Schreibweisen gilt als richtig.
    case textInput(acceptedAnswers: [String])
}

/// Eine einzelne Quizfrage (unveränderlicher Werttyp).
struct Question: Identifiable, Codable, Sendable, Hashable {
    let category: QuizCategory
    let difficulty: Difficulty
    let prompt: String
    let format: AnswerFormat
    /// Kurze Erklärung, die nach der Antwort angezeigt wird (Lerneffekt).
    let explanation: String

    /// Der Fragetext ist im Katalog eindeutig und dient daher als ID.
    var id: String { prompt }

    /// Lesbare Darstellung der richtigen Antwort für das Feedback.
    var correctAnswerText: String {
        switch format {
        case let .multipleChoice(options, correctIndex):
            options.indices.contains(correctIndex) ? options[correctIndex] : "–"
        case .textInput(let acceptedAnswers):
            acceptedAnswers.first ?? "–"
        }
    }
}

/// Antwort der Nutzerin bzw. des Nutzers.
enum UserAnswer: Sendable, Equatable {
    case choice(Int)
    case text(String)
}

// MARK: - Konfiguration und Ergebnis

/// Einstellungen für eine Quizrunde.
struct QuizConfiguration: Identifiable, Hashable, Sendable {
    let id = UUID()
    let categoryFilter: CategoryFilter
    let difficulty: Difficulty
    let questionCount: Int

    static let questionCountOptions = [5, 10, 15]
    static let defaultQuestionCount = 5
}

/// Ergebnis einer abgeschlossenen Runde; wird dauerhaft gespeichert.
struct QuizResult: Identifiable, Codable, Equatable, Sendable {
    var id = UUID()
    var date = Date()
    let categoryFilter: CategoryFilter
    let difficulty: Difficulty
    let score: Int
    let correctFirstTry: Int
    let correctOnRetry: Int
    let totalQuestions: Int
    let bestStreak: Int

    /// Anteil der beim ersten Versuch richtig beantworteten Fragen (0…1).
    var accuracy: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(correctFirstTry) / Double(totalQuestions)
    }

    var ratingText: String {
        switch accuracy {
        case 0.9...: "Hervorragend – dein Gehirn ist top in Form!"
        case 0.6..<0.9: "Gut gemacht – weiter so!"
        default: "Übung macht den Meister – probier es gleich noch einmal."
        }
    }

    var trophySymbol: String {
        switch accuracy {
        case 0.8...: "trophy.fill"
        case 0.5..<0.8: "hand.thumbsup.fill"
        default: "arrow.clockwise.circle.fill"
        }
    }
}
