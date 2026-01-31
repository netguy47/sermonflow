import SwiftUI
import StoreKit

struct MainTimelineView: View {
    @StateObject private var firebaseService = FirebaseService.shared
    @State private var notes: [SermonNote] = []
    @State private var searchText = ""
    @State private var selectedDate: Date? = nil
    @State private var showingEditor = false
    @State private var selectedNote: SermonNote? = nil
    @StateObject private var purchaseManager = PurchaseManager.shared
    @State private var showPaywall = false
    
    private let freeNoteLimit = 5
    
    
    var filteredNotes: [SermonNote] {
        notes.filter { note in
            let matchesSearch = searchText.isEmpty || 
                               note.title.localizedCaseInsensitiveContains(searchText) || 
                               note.body.localizedCaseInsensitiveContains(searchText)
            
            if let selectedDate = selectedDate {
                return matchesSearch && Calendar.current.isDate(note.timestamp, inSameDayAs: selectedDate)
            }
            return matchesSearch
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.parchment.ignoresSafeArea()
                
                if notes.isEmpty {
                    OnboardingView()
                } else {
                    HStack(spacing: 0) {
                        ScrollViewReader { proxy in
                            ScrollView {
                                LazyVStack(spacing: 16) {
                                    ForEach(filteredNotes) { note in
                                        NoteCardView(note: note)
                                            .onTapGesture {
                                                selectedNote = note
                                                showingEditor = true
                                            }
                                            .id(note.id)
                                    }
                                }
                                .padding()
                            }
                        }
                        
                        DateScrubber(notes: notes, selectedDate: $selectedDate)
                    }
                }
            }
            .navigationTitle("Sermon Flow")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search notes or verses...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if !purchaseManager.isSubscribed && notes.count >= freeNoteLimit {
                            showPaywall = true
                        } else {
                            selectedNote = nil
                            showingEditor = true
                        }
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(purchaseManager.isSubscribed || notes.count < freeNoteLimit ? .charcoal : .gray)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if purchaseManager.isSubscribed {
                            // Presentation Mode Logic
                        } else {
                            showPaywall = true
                        }
                    }) {
                        Image(systemName: "play.presentation")
                            .foregroundColor(purchaseManager.isSubscribed ? .sermonGold : .charcoal)
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                            .foregroundColor(.charcoal)
                    }
                }
            }
            .sheet(isPresented: $showingEditor) {
                NoteEditorView(note: selectedNote)
            }
            .sheet(isPresented: $showPaywall) {
                SubscriptionStoreView(groupID: "SF_PREMIUM_GROUP")
                    .subscriptionStoreControlStyle(.picker)
            }
            .onAppear {
                firebaseService.listenToNotes { updatedNotes in
                    self.notes = updatedNotes
                }
                
                // Sign in anonymously if not already
                firebaseService.signInAnonymously { _ in }
            }
        }
        .accentColor(.sermonGold)
    }
}

struct DateScrubber: View {
    let notes: [SermonNote]
    @Binding var selectedDate: Date?
    
    var uniqueDates: [Date] {
        let dates = notes.map { Calendar.current.startOfDay(for: $0.timestamp) }
        return Array(Set(dates)).sorted(by: { $0 > $1 })
    }
    
    var body: some View {
        VStack {
            ForEach(uniqueDates, id: \.self) { date in
                Button(action: {
                    if selectedDate == date {
                        selectedDate = nil
                    } else {
                        selectedDate = date
                    }
                }) {
                    VStack(spacing: 2) {
                        Text(date, format: .dateTime.month(.abbreviated))
                            .font(.system(size: 10, weight: .bold))
                        Text(date, format: .dateTime.day())
                            .font(.system(size: 14, weight: .black))
                    }
                    .foregroundColor(selectedDate == date ? .sermonGold : .charcoal.opacity(0.4))
                    .frame(width: 40)
                    .padding(.vertical, 8)
                }
            }
            Spacer()
        }
        .padding(.vertical)
        .background(Color.charcoal.opacity(0.05))
    }
}

#Preview {
    MainTimelineView()
}
