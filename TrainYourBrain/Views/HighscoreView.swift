import SwiftUI

/// Bestenliste aller gespeicherten Runden.
struct HighscoreView: View {
    @Environment(ScoreStore.self) private var scoreStore
    @Environment(\.dismiss) private var dismiss
    @State private var isConfirmingReset = false

    var body: some View {
        NavigationStack {
            Group {
                if scoreStore.results.isEmpty {
                    ContentUnavailableView(
                        "Noch keine Ergebnisse",
                        systemImage: "trophy",
                        description: Text("Spiele ein Quiz, um hier deine Bestleistungen zu sehen.")
                    )
                } else {
                    List {
                        ForEach(Array(scoreStore.rankedResults.enumerated()), id: \.element.id) { rank, result in
                            HighscoreRow(rank: rank + 1, result: result)
                        }
                    }
                }
            }
            .navigationTitle("Bestenliste")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") { dismiss() }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Zurücksetzen", role: .destructive) { isConfirmingReset = true }
                        .disabled(scoreStore.results.isEmpty)
                }
            }
            .confirmationDialog("Alle Ergebnisse löschen?",
                                isPresented: $isConfirmingReset,
                                titleVisibility: .visible) {
                Button("Löschen", role: .destructive) { scoreStore.reset() }
            }
        }
    }
}

/// Eine Zeile der Bestenliste.
private struct HighscoreRow: View {
    let rank: Int
    let result: QuizResult

    var body: some View {
        HStack(spacing: 12) {
            Text("\(rank).")
                .font(.headline.monospacedDigit())
                .frame(width: 32, alignment: .leading)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(result.categoryFilter.title) · \(result.difficulty.title)")
                    .font(.subheadline.bold())
                Text(result.date, format: .dateTime.day().month().year().hour().minute())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(result.score)")
                .font(.title3.bold().monospacedDigit())
        }
    }
}
