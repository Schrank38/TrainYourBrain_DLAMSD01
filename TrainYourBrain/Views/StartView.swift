import SwiftUI

/// Startbildschirm: Auswahl von Kategorie, Schwierigkeit und Fragenanzahl.
struct StartView: View {
    @Environment(ScoreStore.self) private var scoreStore

    @State private var categoryFilter: CategoryFilter = .all
    @State private var difficulty: Difficulty = .easy
    @State private var questionCount = QuizConfiguration.defaultQuestionCount
    @State private var activeConfiguration: QuizConfiguration?
    @State private var isShowingHighscores = false

    var body: some View {
        NavigationStack {
            Form {
                introSection

                Section("Kategorie") {
                    Picker("Kategorie", selection: $categoryFilter) {
                        ForEach(CategoryFilter.allOptions) { filter in
                            Label(filter.title, systemImage: filter.symbolName)
                                .tag(filter)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                Section {
                    Picker("Schwierigkeit", selection: $difficulty) {
                        ForEach(Difficulty.allCases) { level in
                            Text(level.title).tag(level)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Schwierigkeit")
                } footer: {
                    Text(difficulty.hint)
                }

                Section("Anzahl Fragen") {
                    Picker("Anzahl Fragen", selection: $questionCount) {
                        ForEach(QuizConfiguration.questionCountOptions, id: \.self) { count in
                            Text("\(count)").tag(count)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    if let best = scoreStore.bestScore(for: categoryFilter, difficulty: difficulty) {
                        LabeledContent("Dein Rekord", value: "\(best) Punkte")
                    }
                    Button(action: startQuiz) {
                        Label("Quiz starten", systemImage: "play.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("Train your Brain")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingHighscores = true
                    } label: {
                        Label("Bestenliste", systemImage: "trophy")
                    }
                }
            }
            .sheet(isPresented: $isShowingHighscores) {
                HighscoreView()
                    .environment(scoreStore)
            }
            .fullScreenCover(item: $activeConfiguration) { configuration in
                QuizView(configuration: configuration)
                    .environment(scoreStore)
            }
        }
    }

    private var introSection: some View {
        Section {
            HStack(spacing: 16) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 44))
                    .foregroundStyle(.tint)
                    .accessibilityHidden(true)
                Text("Trainiere dein Allgemeinwissen. Falsch beantwortete Fragen kommen am Ende noch einmal – so bleibt das Wissen hängen.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 6)
        }
    }

    private func startQuiz() {
        activeConfiguration = QuizConfiguration(
            categoryFilter: categoryFilter,
            difficulty: difficulty,
            questionCount: questionCount
        )
    }
}

#Preview {
    StartView()
        .environment(ScoreStore())
}
