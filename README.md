# Train your Brain

Quiz-App für iOS, entwickelt mit SwiftUI und Swift 6. Das Projekt entstand als Projektbericht im Kurs *Apple Mobile Solution Development I (DLAMSD01)* im Studiengang Wirtschaftsinformatik (B.Sc.) an der IU Internationale Hochschule. Dieses Repository enthält den vollständigen Quellcode zum Bericht „Train your Brain – Konzeption und Entwicklung einer iOS-Quiz-App mit SwiftUI und Swift 6“.

## Funktionen

- Fragen aus den Kategorien Geografie, Naturwissenschaft und Informatik oder gemischt
- Drei Schwierigkeitsstufen (Leicht, Mittel, Schwer) mit steigender Punktzahl (10, 20 bzw. 30 Punkte je Frage)
- Antwortformate Multiple Choice und Freitext (Prüfung unabhängig von Groß- und Kleinschreibung, Leerzeichen und Umlauten)
- Serienbonus für aufeinanderfolgende richtige Antworten
- Falsch beantwortete Fragen kehren am Rundenende einmal zurück und zählen dann mit halber Punktzahl
- Feedback nach jeder Antwort mit richtiger Lösung, Erklärung und haptischer Rückmeldung
- Auswertung mit Punktzahl, Trefferquote, längster Serie und der Liste „Zum Nachlernen“
- Dauerhafte Bestenliste und persönlicher Rekord je Kategorie und Schwierigkeit

## Voraussetzungen

| Komponente | Version |
|---|---|
| Xcode | 16.3 |
| Swift | 6 (Strict Concurrency) |
| Mindestversion iOS | 17.0 |
| Abhängigkeiten | keine (nur Apple-Frameworks) |

## Projekt starten

Das Repository enthält die Quelldateien. Falls kein `.xcodeproj` vorhanden ist, wird das Projekt wie folgt aufgesetzt:

1. In Xcode ein neues Projekt anlegen: *File > New > Project > iOS > App*. Product Name `TrainYourBrain`, Interface *SwiftUI*, Language *Swift*, Testing System *Swift Testing*.
2. Die generierten Dateien `ContentView.swift` und `TrainYourBrainApp.swift` löschen.
3. Den Inhalt des Ordners `TrainYourBrain` aus diesem Repository in die Gruppe `TrainYourBrain` im Navigator ziehen („Copy items if needed“ aktivieren, Target `TrainYourBrain`).
4. Den Inhalt von `TrainYourBrainTests` in die Test-Gruppe ziehen, die generierte Testdatei löschen (Target `TrainYourBrainTests`).
5. Unter *Target > General > Minimum Deployments* iOS 17.0 einstellen.
6. Unter *Build Settings* die *Swift Language Version* für App- und Test-Target auf Swift 6 setzen.
7. Einen Simulator wählen (z. B. iPhone 16) und die App mit `Cmd+R` starten.

## Tests

Die Unit-Tests laufen mit `Cmd+U` in Xcode. Sie sind mit Swift Testing geschrieben und umfassen sechs Tests:

- **AnswerEvaluator** (3 Tests): Freitext-Normalisierung, Ablehnung leerer und falscher Eingaben, Multiple-Choice-Vergleich über den Index
- **QuizSession** (3 Tests): Serienbonus, einmalige Wiederholung falscher Fragen mit halber Punktzahl, Persistenz eines gespeicherten Ergebnisses nach erneutem Laden des `ScoreStore`

## Projektstruktur

```
TrainYourBrain/
├── TrainYourBrainApp.swift      App-Einstieg, erzeugt den ScoreStore einmalig
├── Models/
│   ├── QuizModels.swift         Werttypen: Question, AnswerFormat, Difficulty, QuizResult u. a.
│   └── QuestionBank.swift       Fragenkatalog (Namensraum QuestionBank)
├── Logic/
│   ├── QuizSession.swift        Ablaufsteuerung als Zustandsautomat (@MainActor, @Observable)
│   └── AnswerEvaluator.swift    Antwortprüfung und Punkteregeln (ScoringRules)
├── Services/
│   └── ScoreStore.swift         Bestenliste, Speicherung als JSON in UserDefaults
└── Views/
    ├── StartView.swift          Startbildschirm mit Auswahl und Rekordanzeige
    ├── QuizView.swift           Fragebildschirm
    ├── QuizComponents.swift     Antwortkomponenten und Feedback
    ├── ResultView.swift         Auswertung einer Runde
    └── HighscoreView.swift      Bestenliste
TrainYourBrainTests/
└── QuizLogicTests.swift         Unit-Tests
```

## Architektur

Die App folgt dem MVVM-Muster. Die Logik (`QuizSession`, `AnswerEvaluator`, `ScoringRules`) ist von der Oberfläche getrennt und lässt sich deshalb ohne SwiftUI testen. Die Modelle sind unveränderliche, `Sendable`-konforme Werttypen. `QuizSession` und `ScoreStore` sind mit `@MainActor` und `@Observable` annotiert, sodass Zustandsänderungen nur dort stattfinden, wo SwiftUI die Darstellung aktualisiert. Die Begründung der Entwurfsentscheidungen steht im Projektbericht, Kapitel 3 und 6.

## Hinweis

Das Projekt ist ein Prototyp für den Kurs und nicht für den App Store vorgesehen.

## Autor

Okan
