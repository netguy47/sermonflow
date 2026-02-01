import SwiftUI

struct NewNoteView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title: String
    @State private var seriesTitle: String = ""
    @State private var bodyText: String
    @State private var isLifeApplication: Bool
    @State private var detectedVerses: [String] = []
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case title, series, body
    }
    
    var existingNote: SermonNote?
    
    init(note: SermonNote? = nil) {
        self.existingNote = note
        _title = State(initialValue: note?.title ?? "")
        _seriesTitle = State(initialValue: note?.seriesTitle ?? "")
        _bodyText = State(initialValue: note?.body ?? "")
        _isLifeApplication = State(initialValue: note?.isLifeApplication ?? false)
    }
    
    @State private var showingDeleteAlert = false
    
    var isSaveDisabled: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || 
        bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.parchment.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Section 1: Title & Context
                        CardSection {
                            VStack(spacing: 12) {
                                TextField("Sermon Title", text: $title)
                                    .font(SermonFont.title())
                                    .foregroundColor(.charcoal)
                                    .focused($focusedField, equals: .title)
                                    .submitLabel(.next)
                                    .overlay(alignment: .trailing) {
                                        if title.isEmpty && !bodyText.isEmpty {
                                            Button("Suggest Title") {
                                                suggestTitle()
                                            }
                                            .font(SermonFont.caption(size: 10, weight: .bold))
                                            .foregroundColor(.sermonGold)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.sermonGold.opacity(0.1))
                                            .cornerRadius(4)
                                        }
                                    }
                                    .onSubmit {
                                        focusedField = .series
                                    }
                                
                                Divider()
                                
                                HStack {
                                    Image(systemName: "folder")
                                        .foregroundColor(.sermonGold)
                                    TextField("Series (Optional)", text: $seriesTitle)
                                        .font(SermonFont.body(size: 16))
                                        .focused($focusedField, equals: .series)
                                        .submitLabel(.next)
                                        .onSubmit {
                                            focusedField = .body
                                        }
                                }
                            }
                        }
                        .padding(.top, 12)
                        
                        // Section 2: Life Application & Subtitle
                        CardSection {
                            Toggle(isOn: $isLifeApplication.animation(.spring(response: 0.3, dampingFraction: 0.6))) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Life Application")
                                        .font(SermonFont.body(size: 16))
                                        .foregroundColor(.charcoal)
                                    Text("Highlight practical takeaways for later review")
                                        .font(SermonFont.caption(size: 12))
                                        .foregroundColor(.gray)
                                }
                            }
                            .tint(.sermonGold)
                        }
                        
                        // Section 3: Notes & Scripture Detection
                        CardSection(title: "Sermon Notes") {
                            VStack(alignment: .leading, spacing: 16) {
                                PlaceholderTextEditor(
                                    placeholder: "Start writing your sermon notes...",
                                    text: $bodyText,
                                    focusedField: $focusedField,
                                    equals: Field.body
                                )
                                .frame(minHeight: 250)
                                .onChange(of: bodyText) { oldValue, newValue in
                                    withAnimation(.spring()) {
                                        detectVerses(in: newValue)
                                    }
                                }
                                
                                if !detectedVerses.isEmpty {
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack {
                                            Text("Scripture Detected")
                                                .font(SermonFont.serif(size: 12, weight: .bold))
                                                .foregroundColor(.sermonGold)
                                                .textCase(.uppercase)
                                            Spacer()
                                        }
                                        
                                        ForEach(detectedVerses, id: \.self) { ref in
                                            ScriptureBadge(
                                                reference: ref,
                                                verseText: ScriptureEngine.shared.findVerse(reference: ref)
                                            )
                                        }
                                    }
                                    .padding(.horizontal, 4)
                                }
                            }
                        }
                        
                        // Delete Button (only for existing notes)
                        if existingNote != nil {
                            Button(role: .destructive) {
                                showingDeleteAlert = true
                            } label: {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Delete Note")
                                }
                                .font(SermonFont.body(size: 16, weight: .bold))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer(minLength: 120) // Bottom padding for keyboard
                    }
                }
            }
            .navigationTitle(existingNote == nil ? "New Note" : "Edit Note")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Delete Note?", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    deleteNote()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This action cannot be undone. Are you sure you want to permanently delete this sermon note?")
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.charcoal)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveNote()
                    }
                    .font(.headline)
                    .foregroundColor(isSaveDisabled ? .gray : .sermonGold)
                    .disabled(isSaveDisabled)
                }
            }
            .onAppear {
                if existingNote == nil && title.isEmpty {
                    focusedField = .title
                }
            }
        }
    }
    
    private func detectVerses(in text: String) {
        detectedVerses = ScriptureEngine.shared.detectVerses(in: text)
    }
    
    private func suggestTitle() {
        let lines = bodyText.components(separatedBy: .newlines)
        if let firstLine = lines.first(where: { !$0.trimmingCharacters(in: .whitespaces).isEmpty }) {
            let words = firstLine.components(separatedBy: .whitespaces)
            let suggested = words.prefix(5).joined(separator: " ")
            title = suggested + (words.count > 5 ? "..." : "")
            focusedField = .series
        }
    }
    
    private func deleteNote() {
        guard let id = existingNote?.id else { return }
        FirebaseService.shared.deleteNote(id: id) { error in
            if let error = error {
                print("Error deleting note: \(error.localizedDescription)")
            } else {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                dismiss()
            }
        }
    }
    
    private func saveNote() {
        let note = SermonNote(
            id: existingNote?.id,
            title: title,
            body: bodyText,
            timestamp: existingNote?.timestamp ?? Date(),
            isLifeApplication: isLifeApplication,
            seriesTitle: seriesTitle.isEmpty ? nil : seriesTitle
        )
        
        FirebaseService.shared.saveNote(note) { error in
            if let error = error {
                print("Error saving note: \(error.localizedDescription)")
            } else {
                // Sensory feedback on success
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                dismiss()
            }
        }
    }
}

extension View {
    func divider() -> some View {
        VStack(spacing: 0) {
            self
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.charcoal.opacity(0.2))
        }
    }
}

#Preview {
    NewNoteView()
}
