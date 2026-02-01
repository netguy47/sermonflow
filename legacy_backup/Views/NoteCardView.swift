import SwiftUI

struct NoteCardView: View {
    let note: SermonNote
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(note.title)
                    .font(SermonFont.title(size: 20))
                    .foregroundColor(Color.charcoal)
                
                Spacer()
                
                if note.isLifeApplication {
                    Image(systemName: "star.fill")
                        .foregroundColor(.sermonGold)
                }
            }
            
            Text(note.body)
                .font(SermonFont.body())
                .foregroundColor(Color.charcoal)
                .lineLimit(4)
                .multilineTextAlignment(.leading)
            
            HStack {
                Text(note.timestamp, style: .date)
                    .font(SermonFont.caption())
                    .foregroundColor(Color.charcoal.opacity(0.6))
                
                Spacer()
                
                if note.isLifeApplication {
                    Text("Life Application")
                        .font(SermonFont.caption(size: 12))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.sermonGold.opacity(0.2))
                        .cornerRadius(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.sermonGold, lineWidth: 1)
                        )
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.5))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(note.isLifeApplication ? Color.sermonGold : Color.clear, lineWidth: 2)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    ZStack {
        Color.parchment.ignoresSafeArea()
        NoteCardView(note: SermonNote(title: "The Good Shepherd", body: "The Lord is my shepherd; I shall not want. He makes me lie down in green pastures...", timestamp: Date(), isLifeApplication: true))
            .padding()
    }
}
