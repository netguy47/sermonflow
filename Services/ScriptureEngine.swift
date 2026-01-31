import Foundation

struct Verse: Codable {
    let translation: String
    let book: String
    let chapter: Int
    let verse: Int
    let text: String
}

class ScriptureEngine {
    static let shared = ScriptureEngine()
    
    private var bibleData: [String: [Int: [Int: String]]] = [:] // Book -> Chapter -> Verse -> Text
    
    private init() {
        loadBible()
    }
    
    private func loadBible() {
        guard let url = Bundle.main.url(forResource: "web", withExtension: "json") else {
            print("web.json not found")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let verses = try JSONDecoder().decode([Verse].self, from: data)
            
            // Index for fast lookup
            for v in verses {
                if bibleData[v.book] == nil {
                    bibleData[v.book] = [:]
                }
                if bibleData[v.book]?[v.chapter] == nil {
                    bibleData[v.book]?[v.chapter] = [:]
                }
                bibleData[v.book]?[v.chapter]?[v.verse] = v.text
            }
        } catch {
            print("Error decoding web.json: \(error)")
        }
    }
    
    func findVerse(reference: String) -> String? {
        // Simple regex to parse "John 3:16" or "1 John 1:9"
        let pattern = #"^(.+)\s(\d+):(\d+)$"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: reference, options: [], range: NSRange(location: 0, length: reference.utf16.count)) else {
            return nil
        }
        
        let bookName = (reference as NSString).substring(with: match.range(at: 1)).trimmingCharacters(in: .whitespaces)
        let chapter = Int((reference as NSString).substring(with: match.range(at: 2))) ?? 0
        let verse = Int((reference as NSString).substring(with: match.range(at: 3))) ?? 0
        
        // Try exact match first
        if let text = bibleData[bookName]?[chapter]?[verse] {
            return text
        }
        
        // Try case-insensitive book match
        if let bookKey = bibleData.keys.first(where: { $0.lowercased() == bookName.lowercased() }) {
            return bibleData[bookKey]?[chapter]?[verse]
        }
        
        return nil
    }
    
    // Function to search for verse references in a string of text
    func detectVerses(in text: String) -> [String] {
        let pattern = #"\b([1-3]?\s?[A-Za-z]+)\s(\d+):(\d+)\b"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return [] }
        
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
        return matches.map { (text as NSString).substring(with: $0.range) }
    }
}
