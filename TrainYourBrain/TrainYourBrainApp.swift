import SwiftUI

/// Einstiegspunkt der App.
/// Der `ScoreStore` wird genau einmal erzeugt und über das Environment
/// an alle Views weitergereicht (Single Source of Truth für Ergebnisse).
@main
struct TrainYourBrainApp: App {
    @State private var scoreStore = ScoreStore()

    var body: some Scene {
        WindowGroup {
            StartView()
                .environment(scoreStore)
        }
    }
}
