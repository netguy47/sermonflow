import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class FirebaseService: ObservableObject {
    static let shared = FirebaseService()
    
    private var db: Firestore {
        return Firestore.firestore()
    }
    
    private init() {
        // FirebaseApp.configure() is usually called in the App's init
        setupFirestore()
    }
    
    private func setupFirestore() {
        let settings = FirestoreSettings()
        // Firestore has offline persistence enabled by default on iOS, 
        // but we can explicitly set it if needed.
        settings.isPersistenceEnabled = true
        settings.cacheSettings = PersistentCacheSettings()
        db.settings = settings
    }
    
    func signInAnonymously(completion: @escaping (Result<String, Error>) -> Void) {
        Auth.auth().signInAnonymously { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let user = authResult?.user else {
                completion(.failure(NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user found"])))
                return
            }
            completion(.success(user.uid))
        }
    }
    
    func saveNote(_ note: SermonNote, completion: @escaping (Error?) -> Void) {
        do {
            _ = try db.collection("notes").addDocument(from: note, completion: completion)
        } catch {
            completion(error)
        }
    }
    
    func listenToNotes(completion: @escaping ([SermonNote]) -> Void) {
        db.collection("notes")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching notes: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                let notes = documents.compactMap { doc -> SermonNote? in
                    try? doc.data(as: SermonNote.self)
                }
                completion(notes)
            }
    }
}
