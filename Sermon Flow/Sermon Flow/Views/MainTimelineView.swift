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
    @State private var shareURL: URL? = nil
    @State private var showingShareSheet = false
    @State private var scrollToTopTrigger = false
    
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
                            ZStack(alignment: .bottomTrailing) {
                                List {
                                    Color.clear
                                        .frame(height: 1)
                                        .id("top")
                                        .listRowBackground(Color.clear)
                                        .listRowSeparator(.hidden)
                                        .listRowInsets(EdgeInsets())
                                    
                                    ForEach(filteredNotes) { note in
                                        NoteCardView(
                                            note: note,
                                            onDelete: { deleteNote(note) },
                                            onExport: { exportToPDF(note: note) }
                                        )
                                        .listRowBackground(Color.clear)
                                        .listRowSeparator(.hidden)
                                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                        .onTapGesture {
                                            selectedNote = note
                                            showingEditor = true
                                        }
                                        .id(note.id)
                                    }
                                    .onDelete { indexSet in
                                        for index in indexSet {
                                            deleteNote(filteredNotes[index])
                                        }
                                    }
                                }
                                .listStyle(.plain)
                                .onChange(of: notes.count) { _ in
                                    // Optional: logic to scroll to top on new note
                                }
                                .onChange(of: scrollToTopTrigger) { _ in
                                    withAnimation(.spring()) {
                                        proxy.scrollTo("top", anchor: .top)
                                    }
                                }
                                
                                // Floating Scroll to Top Button
                                Button(action: {
                                    scrollToTopTrigger.toggle()
                                }) {
                                    Image(systemName: "chevron.up")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.sermonGold)
                                        .clipShape(Circle())
                                        .shadow(radius: 4)
                                }
                                .padding(.trailing, 20)
                                .padding(.bottom, 20)
                            }
                        }
                        
                        DateScrubber(notes: notes, selectedDate: $selectedDate)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Button(action: {
                        scrollToTopTrigger.toggle()
                    }) {
                        HStack(spacing: 4) {
                            Text("Sermon Flow")
                                .font(SermonFont.serif(size: 20, weight: .bold))
                            Image(systemName: "chevron.up.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.sermonGold)
                        }
                        .foregroundColor(.black)
                    }
                }
                
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
            .searchable(text: $searchText, prompt: "Search notes or verses...")
            .sheet(isPresented: $showingEditor) {
                NewNoteView(note: selectedNote)
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
        .sheet(isPresented: $showingShareSheet) {
            if let url = shareURL {
                ShareSheet(activityItems: [url])
            }
        }
        .accentColor(.sermonGold)
    }
    
    private func deleteNote(_ note: SermonNote) {
        guard let id = note.id else { return }
        firebaseService.deleteNote(id: id) { error in
            if let error = error {
                print("Error deleting note: \(error.localizedDescription)")
            } else {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
            }
        }
    }
    
    private func exportToPDF(note: SermonNote) {
        if let url = PDFManager.shared.generatePDF(from: note) {
            self.shareURL = url
            self.showingShareSheet = true
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
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
