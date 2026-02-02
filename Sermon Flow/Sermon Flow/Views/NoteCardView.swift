import SwiftUI

struct NoteCardView: View {
    let note: SermonNote
    var onDelete: (() -> Void)? = nil
    var onExport: (() -> Void)? = nil
    var onPlay: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(note.title)
                        .font(SermonFont.title(size: 20))
                        .foregroundColor(Color.charcoal)
                    
                    if let series = note.seriesTitle {
                        Text(series)
                            .font(SermonFont.caption(size: 14))
                            .foregroundColor(.sermonGold)
                            .italic()
                    }
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    if note.isLifeApplication {
                        Image(systemName: "star.fill")
                            .foregroundColor(.sermonGold)
                    }
                    
                    Menu {
                        if let onPlay = onPlay {
                            Button(action: onPlay) {
                                Label("Play Session", systemImage: "play.presentation")
                            }
                        }
                        
                        if let onExport = onExport {
                            Button(action: onExport) {
                                Label("Export to PDF", systemImage: "doc.richtext")
                            }
                        }
                        
                        if let onDelete = onDelete {
                            Button(role: .destructive, action: onDelete) {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 22))
                            .foregroundColor(.sermonGold)
                    }
                }
            }
            
            Text(note.body)
                .font(SermonFont.body())
                .foregroundColor(Color.charcoal) // Solid black/dark
                .lineLimit(4)
                .multilineTextAlignment(.leading)
            
            if let verses = note.detectedVerses, !verses.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(verses, id: \.self) { ref in
                            HStack(spacing: 4) {
                                Image(systemName: "book.fill")
                                    .font(.system(size: 10))
                                Text(ref)
                                    .font(SermonFont.caption(size: 11, weight: .bold))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.sermonGold.opacity(0.12))
                            .foregroundColor(.sermonGoldDark)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.sermonGoldDark.opacity(0.2), lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(.top, 4)
            }
            
            HStack {
                Text(note.timestamp, style: .date)
                    .font(SermonFont.caption(size: 12, weight: .bold)) // Darker + Bold
                    .foregroundColor(Color.charcoal.opacity(0.7)) // Increased from 0.5
                
                if note.id != nil {
                    Image(systemName: "icloud.and.arrow.up")
                        .font(.system(size: 10))
                        .foregroundColor(.sermonGoldDark.opacity(0.6))
                        .help("Synced to Cloud")
                }
                
                Spacer()
                
                if note.isLifeApplication {
                    Text("Life Application")
                        .font(SermonFont.caption(size: 11, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .foregroundColor(.sermonGoldDark)
                        .background(Color.sermonGold.opacity(0.12))
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.sermonGoldDark.opacity(0.2), lineWidth: 1)
                        )
                }
            }
        }
        .padding(18) // Increased internal padding for better breathing room
        .background(Color.white.opacity(0.55))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(note.isLifeApplication ? Color.sermonGoldDark.opacity(0.3) : Color.clear, lineWidth: 1.5)
        )
        .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 3)
        .contentShape(Rectangle())
    }
}

#Preview {
    ZStack {
        Color.parchment.ignoresSafeArea()
        NoteCardView(note: SermonNote(title: "The Good Shepherd", body: "The Lord is my shepherd; I shall not want. He makes me lie down in green pastures...", timestamp: Date(), isLifeApplication: true))
            .padding()
    }
}
