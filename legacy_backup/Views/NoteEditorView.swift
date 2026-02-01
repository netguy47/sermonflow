import SwiftUI

struct NoteEditorView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title: String
    @State private var bodyText: String
    @State private var isLifeApplication: Bool
    @State private var detectedVerses: [String] = []
    
    var existingNote: SermonNote?
    
    init(note: SermonNote? = nil) {
        self.existingNote = note
        _title = State(initialValue: note?.title ?? "")
        _bodyText = State(initialValue: note?.body ?? "")
        _isLifeApplication = State(initialValue: note?.isLifeApplication ?? false)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.parchment.ignoresSafeArea()
                
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            TextField("Sermon Title", text: $title)
                                .font(SermonFont.title())
                                .foregroundColor(.charcoal)
                                .padding(.bottom, 8)
                                .divider()
                            
                            Toggle(isOn: $isLifeApplication) {
                                Text("Life Application")
                                    .font(SermonFont.body(size: 16))
                                    .foregroundColor(.charcoal)
                            }
                            .tint(.sermonGold)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(isLifeApplication ? Color.sermonGold.opacity(0.1) : Color.clear)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isLifeApplication ? Color.sermonGold : Color.charcoal.opacity(0.2), lineWidth: 1)
                            )
                            
                            TextEditor(text: $bodyText)
                                .font(SermonFont.body())
                                .foregroundColor(.charcoal)
                                .frame(minHeight: 300)
                                .scrollContentBackground(.hidden)
                                .onChange(of: bodyText) { newValue in
                                    detectVerses(in: newValue)
                                    // Logic to ensure the cursor stays visible could go here
                                    // with proxy.scrollTo(...) if we have specific anchors
                                }
                                .id("editor")
                            
                            if !detectedVerses.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Scripture Detected:")
                                        .font(SermonFont.caption(size: 12))
                                        .foregroundColor(.sermonGold)
                                    
                                    ForEach(detectedVerses, id: \.self) { ref in
                                        if let verseText = ScriptureEngine.shared.findVerse(reference: ref) {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(ref)
                                                    .font(SermonFont.serif(size: 14, weight: .bold))
                                                Text(verseText)
                                                    .font(SermonFont.serif(size: 14))
                                                    .italic()
                                            }
                                            .padding(8)
                                            .background(Color.white.opacity(0.8))
                                            .cornerRadius(6)
                                        }
                                    }
                                }
                                .padding(.top)
                                .id("verses")
                            }
                            
                            Spacer(minLength: 100)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle(existingNote == nil ? "New Note" : "Edit Note")
            .navigationBarTitleDisplayMode(.inline)
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
                    .foregroundColor(.sermonGold)
                    .disabled(title.isEmpty || bodyText.isEmpty)
                }
            }
        }
    }
    
    private func detectVerses(in text: String) {
        detectedVerses = ScriptureEngine.shared.detectVerses(in: text)
    }
    
    private func saveNote() {
        let note = SermonNote(
            id: existingNote?.id,
            title: title,
            body: bodyText,
            timestamp: existingNote?.timestamp ?? Date(),
            isLifeApplication: isLifeApplication
        )
        
        FirebaseService.shared.saveNote(note) { error in
            if let error = error {
                print("Error saving note: \(error.localizedDescription)")
            } else {
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
    NoteEditorView()
}
