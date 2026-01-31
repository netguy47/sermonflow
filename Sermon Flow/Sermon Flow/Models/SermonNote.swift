import Foundation
import FirebaseFirestore

struct SermonNote: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var body: String
    var timestamp: Date
    var isLifeApplication: Bool
    
    init(id: String? = nil, title: String, body: String, timestamp: Date = Date(), isLifeApplication: Bool = false) {
        self.id = id
        self.title = title
        self.body = body
        self.timestamp = timestamp
        self.isLifeApplication = isLifeApplication
    }
}
