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
    @AppStorage("mondayRecallEnabled") private var mondayRecallEnabled = true
    
    var isSaveDisabled: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || 
        bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.parchment.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 28) { // Normalized rhythm
                        // Title Section
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "pencil.line")
                                    .foregroundColor(focusedField == .title ? .sermonGold : .charcoal)
                                Text("SERMON TITLE")
                                    .font(SermonFont.caption(size: 11, weight: .black))
                                    .foregroundColor(focusedField == .title ? .sermonGoldDark : .charcoal.opacity(0.7))
                                    .kerning(1.2)
                            }
                            
                            TextField("What is this message called?", text: $title)
                                .font(SermonFont.title(size: 24))
                                .foregroundColor(.charcoal)
                                .focused($focusedField, equals: .title)
                                .overlay(alignment: .trailing) {
                                    if !title.isEmpty {
                                        Button(action: { title = "" }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.gray.opacity(0.3))
                                        }
                                    }
                                }
                            
                            Divider()
                                .background(focusedField == .title ? Color.sermonGold : Color.gray.opacity(0.3))
                                .scaleEffect(y: focusedField == .title ? 1.5 : 1.0)
                        }
                        
                        // Series Section
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "folder")
                                    .foregroundColor(focusedField == .series ? .sermonGold : .charcoal)
                                Text("SERMON SERIES")
                                    .font(SermonFont.caption(size: 11, weight: .black))
                                    .foregroundColor(focusedField == .series ? .sermonGoldDark : .charcoal.opacity(0.7))
                                    .kerning(1.2)
                            }
                            
                            TextField("e.g. The King of Kings (Optional)", text: $seriesTitle)
                                .font(SermonFont.body(size: 18))
                                .foregroundColor(.charcoal)
                                .focused($focusedField, equals: .series)
                            
                            Divider()
                                .background(focusedField == .series ? Color.sermonGold : Color.gray.opacity(0.3))
                                .scaleEffect(y: focusedField == .series ? 1.5 : 1.0)
                        }
                        
                        // Life Application Toggle Section
                        VStack(alignment: .leading, spacing: 12) {
                            Toggle(isOn: $isLifeApplication.animation(.spring())) {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.sermonGold)
                                        Text("LIFE APPLICATION")
                                            .font(SermonFont.caption(size: 11, weight: .black))
                                            .foregroundColor(.charcoal.opacity(0.7))
                                            .kerning(1.2)
                                    }
                                    Text("Flag this as a practical takeaway for Monday recall")
                                        .font(SermonFont.caption(size: 12))
                                        .foregroundColor(.charcoal.opacity(0.5))
                                }
                            }
                            .tint(.sermonGoldDark)
                            
                            Divider()
                                .background(Color.gray.opacity(0.2))
                        }
                        
                        // Body Notes Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "text.alignleft")
                                    .foregroundColor(focusedField == .body ? .sermonGold : .charcoal)
                                Text("NOTES & SCRIPTURE")
                                    .font(SermonFont.caption(size: 11, weight: .black))
                                    .foregroundColor(focusedField == .body ? .sermonGoldDark : .charcoal.opacity(0.7))
                                    .kerning(1.2)
                                
                                Spacer()
                                
                                if !bodyText.isEmpty && title.isEmpty {
                                    Button(action: suggestTitle) {
                                        HStack(spacing: 4) {
                                            Text("Suggest Title")
                                            Image(systemName: "wand.and.stars")
                                        }
                                        .font(SermonFont.caption(size: 11, weight: .bold))
                                        .padding(.horizontal, 14) // Increased tap target width
                                        .padding(.vertical, 8)    // Increased tap target height
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.sermonGold.opacity(0.12))
                                        )
                                        .foregroundColor(.sermonGoldDark)
                                    }
                                    .contentShape(Rectangle()) // Ensure full area is tappable
                                    .transition(.move(edge: .trailing).combined(with: .opacity))
                                }
                            }
                            
                            ZStack(alignment: .topLeading) {
                                if bodyText.isEmpty {
                                    Text("Begin typing your notes here...")
                                        .font(SermonFont.body(size: 18))
                                        .foregroundColor(.charcoal.opacity(0.45)) // Improved contrast
                                        .padding(.top, 10)
        
                                        .padding(.leading, 4)
                                }
                                
                                TextEditor(text: $bodyText)
                                    .font(SermonFont.body(size: 18))
                                    .foregroundColor(.charcoal)
                                    .frame(minHeight: 300)
                                    .focused($focusedField, equals: .body)
                                    .scrollContentBackground(.hidden)
                                    .onChange(of: bodyText) { oldValue, newValue in
                                        detectVerses(in: newValue)
                                    }
                            }
                            
                            // Interactive Scripture Detection
                            if !detectedVerses.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("SCRIPTURE DETECTED")
                                        .font(SermonFont.caption(size: 11, weight: .black))
                                        .foregroundColor(.sermonGoldDark)
                                        .kerning(1.2)
                                    
                                    VStack(spacing: 12) {
                                        ForEach(detectedVerses, id: \.self) { ref in
                                            ScriptureBadge(
                                                reference: ref,
                                                verseText: ScriptureEngine.shared.findVerse(reference: ref),
                                                onInsertText: { insertScripture(ref: ref, includeText: true) },
                                                onInsertReference: { insertScripture(ref: ref, includeText: false) }
                                            )
                                        }
                                    }
                                }
                                .padding(.top, 8)
                                .transition(.asymmetric(insertion: .push(from: .bottom), removal: .opacity))
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
                            .padding(.vertical, 16)
                        }
                        
                        Spacer(minLength: 120)
                    }
                    .padding(20)
                }
            }
            .navigationTitle(existingNote == nil ? "New Note" : "Edit Note")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Delete Note?", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) { deleteNote() }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This action cannot be undone. Are you sure you want to permanently delete this sermon note?")
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.charcoal)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveNote() }
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
    
    private func insertScripture(ref: String, includeText: Bool) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        // Define what we're inserting
        var insertion = "(\(ref))"
        if includeText, let text = ScriptureEngine.shared.findVerse(reference: ref) {
            insertion = "\"\(text)\" (\(ref))"
        }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            // Bulletproof In-Place Replacement:
            // Find the most likely occurrence of the reference in the text
            if let range = bodyText.range(of: ref, options: .backwards) {
                // If the reference is already in parentheses, replace the whole thing
                // Otherwise, just replace the reference string
                bodyText.replaceSubrange(range, with: insertion)
            } else {
                // Fallback to appending if for some reason the reference isn't found
                bodyText += "\n" + insertion
            }
            detectVerses(in: bodyText)
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
            seriesTitle: seriesTitle.isEmpty ? nil : seriesTitle,
            detectedVerses: detectedVerses.isEmpty ? nil : detectedVerses
        )
        
        FirebaseService.shared.saveNote(note) { error in
            if let error = error {
                print("Error saving note: \(error.localizedDescription)")
            } else {
                // Schedule Monday Recall if enabled
                if isLifeApplication && mondayRecallEnabled {
                    NotificationManager.shared.scheduleMondayRecall(for: note)
                }
                
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
