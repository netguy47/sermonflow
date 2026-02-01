import Foundation

struct SermonSeries: Identifiable, Codable {
    var id: String
    var title: String
    var description: String?
    var artworkURL: String?
    
    init(id: String = UUID().uuidString, title: String, description: String? = nil, artworkURL: String? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.artworkURL = artworkURL
    }
}
