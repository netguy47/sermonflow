import SwiftUI

struct ScriptureBadge: View {
    let reference: String
    let verseText: String?
    var onInsertText: (() -> Void)? = nil
    var onInsertReference: (() -> Void)? = nil
    
    var body: some View {
        Menu {
            if let onInsertText = onInsertText, let verseText = verseText {
                Button(action: onInsertText) {
                    Label("Expand to Full Verse", systemImage: "plus.magnifyingglass")
                }
            }
            
            if let onInsertReference = onInsertReference {
                Button(action: onInsertReference) {
                    Label("Wrap in Parentheses", systemImage: "parentheses")
                }
            }
            
            Button(action: { UIPasteboard.general.string = reference }) {
                Label("Copy Reference", systemImage: "doc.on.doc")
            }
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(reference)
                        .font(SermonFont.serif(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "plus.circle.fill")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                if let verse = verseText {
                    Text(verse)
                        .font(SermonFont.serif(size: 14))
                        .italic()
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(3)
                }
            }
            .padding(12)
            .background(
                LinearGradient(
                    colors: [Color.sermonGoldDark, Color.sermonGold],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
            .shadow(color: Color.sermonGold.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .transition(.asymmetric(
            insertion: .opacity.combined(with: .move(edge: .bottom)).combined(with: .scale(scale: 0.95)),
            removal: .opacity.combined(with: .scale(scale: 0.95))
        ))
    }
}
