import Foundation
import Observation
import OSLog

/// Speichert Quizergebnisse dauerhaft als JSON in `UserDefaults`.
/// Für die kleine Datenmenge ist das ausreichend; `UserDefaults` ist
/// über den Initialisierer austauschbar (Tests).
@MainActor
@Observable
final class ScoreStore {

    private(set) var results: [QuizResult] = []

    private let defaults: UserDefaults
    private let storageKey = "trainYourBrain.results"
    private let maxStoredResults = 50
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "TrainYourBrain",
        category: "ScoreStore"
    )

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
    }

    /// Ergebnisse absteigend nach Punktzahl.
    var rankedResults: [QuizResult] {
        results.sorted { $0.score > $1.score }
    }

    /// Bestwert für eine Kombination aus Kategorie und Schwierigkeit.
    func bestScore(for filter: CategoryFilter, difficulty: Difficulty) -> Int? {
        results
            .filter { $0.categoryFilter == filter && $0.difficulty == difficulty }
            .map(\.score)
            .max()
    }

    func record(_ result: QuizResult) {
        guard !results.contains(where: { $0.id == result.id }) else { return }
        results.append(result)
        // Nur die besten Ergebnisse behalten, damit der Speicher klein bleibt.
        if results.count > maxStoredResults {
            results = Array(rankedResults.prefix(maxStoredResults))
        }
        save()
    }

    func reset() {
        results.removeAll()
        defaults.removeObject(forKey: storageKey)
    }

    // MARK: Persistenz

    private func load() {
        guard let data = defaults.data(forKey: storageKey) else { return }
        do {
            results = try JSONDecoder().decode([QuizResult].self, from: data)
        } catch {
            Self.logger.error("Ergebnisse konnten nicht geladen werden: \(error.localizedDescription)")
            results = []
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(results)
            defaults.set(data, forKey: storageKey)
        } catch {
            Self.logger.error("Ergebnisse konnten nicht gespeichert werden: \(error.localizedDescription)")
        }
    }
}
