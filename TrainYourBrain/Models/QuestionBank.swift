import Foundation

/// Statischer Fragenkatalog. Als `enum` ohne Cases kann er nicht
/// instanziiert werden und dient nur als Namensraum.
enum QuestionBank {

    /// Liefert eine gemischte Fragenliste passend zur Konfiguration.
    /// Gibt es zu wenige Fragen in der gewählten Stufe, wird mit Fragen
    /// der nächstgelegenen Stufen aufgefüllt.
    static func questions(for configuration: QuizConfiguration) -> [Question] {
        let target = configuration.difficulty.rawValue
        let pool = all.filter { configuration.categoryFilter.includes($0.category) }

        let exactMatches = pool
            .filter { $0.difficulty == configuration.difficulty }
            .shuffled()
        let fillers = pool
            .filter { $0.difficulty != configuration.difficulty }
            .shuffled()
            .sorted { abs($0.difficulty.rawValue - target) < abs($1.difficulty.rawValue - target) }

        return Array((exactMatches + fillers).prefix(configuration.questionCount)).shuffled()
    }

    // MARK: Fabrikmethoden (machen den Katalog kompakt und lesbar)

    private static func choice(
        _ category: QuizCategory, _ difficulty: Difficulty, _ prompt: String,
        options: [String], correct: Int, explanation: String
    ) -> Question {
        Question(category: category, difficulty: difficulty, prompt: prompt,
                 format: .multipleChoice(options: options, correctIndex: correct),
                 explanation: explanation)
    }

    private static func text(
        _ category: QuizCategory, _ difficulty: Difficulty, _ prompt: String,
        answers: [String], explanation: String
    ) -> Question {
        Question(category: category, difficulty: difficulty, prompt: prompt,
                 format: .textInput(acceptedAnswers: answers),
                 explanation: explanation)
    }

    // MARK: Katalog

    static let all: [Question] = [
        // Geografie – leicht
        choice(.geography, .easy, "Was ist die Hauptstadt von Frankreich?",
               options: ["Lyon", "Paris", "Marseille", "Nizza"], correct: 1,
               explanation: "Paris ist seit dem Mittelalter Hauptstadt Frankreichs."),
        text(.geography, .easy, "Wie heißt die Hauptstadt von Italien?",
             answers: ["Rom", "Roma"],
             explanation: "Rom ist Hauptstadt Italiens und umschließt die Vatikanstadt."),
        choice(.geography, .easy, "Welcher Kontinent ist flächenmäßig der größte?",
               options: ["Afrika", "Nordamerika", "Asien", "Europa"], correct: 2,
               explanation: "Asien umfasst rund 30 % der Landfläche der Erde."),
        choice(.geography, .easy, "Welcher Fluss fließt durch Köln?",
               options: ["Rhein", "Elbe", "Donau", "Main"], correct: 0,
               explanation: "Köln liegt am Rhein."),

        // Geografie – mittel
        text(.geography, .medium, "Wie heißt die Hauptstadt von Kanada?",
             answers: ["Ottawa"],
             explanation: "Nicht Toronto oder Montreal – Hauptstadt ist Ottawa."),
        choice(.geography, .medium, "Welches ist der längste Fluss Europas?",
               options: ["Donau", "Rhein", "Wolga", "Dnepr"], correct: 2,
               explanation: "Die Wolga ist rund 3.500 km lang."),
        choice(.geography, .medium, "In welchem Land liegt die Stadt Marrakesch?",
               options: ["Tunesien", "Marokko", "Algerien", "Ägypten"], correct: 1,
               explanation: "Marrakesch ist eine der Königsstädte Marokkos."),
        text(.geography, .medium, "Wie heißt der höchste Berg Deutschlands?",
             answers: ["Zugspitze", "Die Zugspitze"],
             explanation: "Die Zugspitze ist 2.962 m hoch."),

        // Geografie – schwer
        choice(.geography, .hard, "Wie heißt die Hauptstadt von Australien?",
               options: ["Sydney", "Melbourne", "Canberra", "Perth"], correct: 2,
               explanation: "Canberra wurde als Kompromiss zwischen Sydney und Melbourne gegründet."),
        text(.geography, .hard, "Welcher Staat ist flächenmäßig der kleinste der Welt?",
             answers: ["Vatikanstadt", "Vatikan", "Staat der Vatikanstadt"],
             explanation: "Die Vatikanstadt ist nur etwa 0,44 km² groß."),
        choice(.geography, .hard, "Welcher See ist der tiefste der Erde?",
               options: ["Tanganjikasee", "Baikalsee", "Kaspisches Meer", "Lago Maggiore"], correct: 1,
               explanation: "Der Baikalsee in Sibirien ist über 1.600 m tief."),
        text(.geography, .hard, "Wie heißt die Hauptstadt der Mongolei?",
             answers: ["Ulaanbaatar", "Ulan Bator", "Ulan-Bator"],
             explanation: "Ulaanbaatar gilt als kälteste Hauptstadt der Welt."),

        // Naturwissenschaft – leicht
        text(.science, .easy, "Wie lautet die chemische Summenformel von Wasser?",
             answers: ["H2O", "H₂O"],
             explanation: "Ein Wassermolekül besteht aus zwei Wasserstoff- und einem Sauerstoffatom."),
        choice(.science, .easy, "Wie viele Planeten hat unser Sonnensystem?",
               options: ["7", "8", "9", "10"], correct: 1,
               explanation: "Seit 2006 zählt Pluto als Zwergplanet – es bleiben 8 Planeten."),
        choice(.science, .easy, "Welches Gas nehmen Pflanzen für die Photosynthese auf?",
               options: ["Sauerstoff", "Stickstoff", "Kohlenstoffdioxid", "Helium"], correct: 2,
               explanation: "Pflanzen binden CO₂ und geben Sauerstoff ab."),
        text(.science, .easy, "Bei wie viel Grad Celsius siedet Wasser auf Meereshöhe?",
             answers: ["100", "100 °C", "100°C", "100 Grad"],
             explanation: "Bei Normaldruck (1013 hPa) siedet Wasser bei 100 °C."),

        // Naturwissenschaft – mittel
        choice(.science, .medium, "Welches chemische Element hat das Symbol „Fe“?",
               options: ["Fluor", "Eisen", "Phosphor", "Blei"], correct: 1,
               explanation: "Fe kommt vom lateinischen „ferrum“ (Eisen)."),
        text(.science, .medium, "Welcher Planet wird als „Roter Planet“ bezeichnet?",
             answers: ["Mars"],
             explanation: "Eisenoxid auf der Oberfläche färbt den Mars rötlich."),
        choice(.science, .medium, "Wie heißt die kleinste Einheit eines chemischen Elements?",
               options: ["Molekül", "Atom", "Zelle", "Ion"], correct: 1,
               explanation: "Ein Atom ist die kleinste Einheit, die die Eigenschaften eines Elements trägt."),
        choice(.science, .medium, "Wie schnell breitet sich Licht im Vakuum ungefähr aus?",
               options: ["300.000 km/s", "30.000 km/s", "3.000 km/s", "1.080 km/h"], correct: 0,
               explanation: "Die Lichtgeschwindigkeit beträgt etwa 299.792 km/s."),

        // Naturwissenschaft – schwer
        text(.science, .hard, "Welche Ordnungszahl hat Kohlenstoff im Periodensystem?",
             answers: ["6", "sechs"],
             explanation: "Kohlenstoff besitzt 6 Protonen im Kern."),
        choice(.science, .hard, "Welches Organell gilt als „Kraftwerk der Zelle“?",
               options: ["Ribosom", "Golgi-Apparat", "Mitochondrium", "Zellkern"], correct: 2,
               explanation: "Mitochondrien erzeugen den Großteil des Energieträgers ATP."),
        text(.science, .hard, "Wie lautet das chemische Symbol für Gold?",
             answers: ["Au"],
             explanation: "Au leitet sich vom lateinischen „aurum“ ab."),
        choice(.science, .hard, "Welche physikalische Größe wird in Pascal gemessen?",
               options: ["Druck", "Energie", "Leistung", "Frequenz"], correct: 0,
               explanation: "1 Pascal entspricht 1 Newton pro Quadratmeter."),

        // Informatik – leicht
        choice(.computing, .easy, "Wofür steht die Abkürzung „CPU“?",
               options: ["Central Processing Unit", "Computer Power Unit",
                         "Central Program Utility", "Core Processing Unit"], correct: 0,
               explanation: "Die CPU ist der Hauptprozessor eines Computers."),
        text(.computing, .easy, "Wie viele Bit hat ein Byte?",
             answers: ["8", "acht"],
             explanation: "Ein Byte besteht aus 8 Bit und kann 256 Werte darstellen."),
        choice(.computing, .easy, "Welche Programmiersprache empfiehlt Apple für iOS-Apps?",
               options: ["Kotlin", "Swift", "C#", "Java"], correct: 1,
               explanation: "Swift wurde 2014 von Apple vorgestellt."),
        choice(.computing, .easy, "Welches Zahlensystem verwenden Computer intern?",
               options: ["Dezimalsystem", "Hexadezimalsystem", "Binärsystem", "Oktalsystem"], correct: 2,
               explanation: "Computer rechnen mit den Zuständen 0 und 1."),

        // Informatik – mittel
        text(.computing, .medium, "Mit welchem Swift-Schlüsselwort deklariert man eine Konstante?",
             answers: ["let"],
             explanation: "`let` deklariert Konstanten, `var` veränderliche Variablen."),
        choice(.computing, .medium, "Welche Datenstruktur arbeitet nach dem LIFO-Prinzip?",
               options: ["Queue", "Stack", "Baum", "Hashtabelle"], correct: 1,
               explanation: "Beim Stack wird das zuletzt abgelegte Element zuerst entnommen."),
        choice(.computing, .medium, "Wie heißt Apples deklaratives UI-Framework?",
               options: ["UIKit", "AppKit", "SwiftUI", "SpriteKit"], correct: 2,
               explanation: "SwiftUI beschreibt Oberflächen deklarativ als Funktion des Zustands."),
        text(.computing, .medium, "Welche Dezimalzahl entspricht der Binärzahl 1010?",
             answers: ["10", "zehn"],
             explanation: "1·8 + 0·4 + 1·2 + 0·1 = 10."),

        // Informatik – schwer
        choice(.computing, .hard, "Welche Zeitkomplexität hat die binäre Suche in einem sortierten Array?",
               options: ["O(n)", "O(log n)", "O(n log n)", "O(1)"], correct: 1,
               explanation: "Der Suchbereich halbiert sich in jedem Schritt."),
        text(.computing, .hard,
             "Wie heißt das Swift-Protokoll, das Typen als sicher zwischen Nebenläufigkeitsdomänen übertragbar kennzeichnet?",
             answers: ["Sendable"],
             explanation: "`Sendable` ist zentral für die Data-Race-Sicherheit in Swift 6."),
        choice(.computing, .hard, "Wofür steht „ACID“ bei Datenbanktransaktionen?",
               options: ["Atomicity, Consistency, Isolation, Durability",
                         "Access, Control, Integrity, Data",
                         "Atomicity, Concurrency, Indexing, Durability",
                         "Availability, Consistency, Isolation, Distribution"], correct: 0,
               explanation: "ACID beschreibt die Eigenschaften zuverlässiger Transaktionen."),
        text(.computing, .hard, "Wie lautet die Hexadezimaldarstellung der Dezimalzahl 255?",
             answers: ["FF", "0xFF"],
             explanation: "255 = 15·16 + 15, also FF."),
    ]
}
