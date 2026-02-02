import SwiftUI

struct PresentationModeView: View {
    let note: SermonNote
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.parchment.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Persistent Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(note.title)
                            .font(SermonFont.serif(size: 24, weight: .bold))
                            .foregroundColor(.charcoal)
                        
                        if let series = note.seriesTitle {
                            Text(series)
                                .font(SermonFont.caption(size: 14))
                                .foregroundColor(.sermonGoldDark)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.charcoal.opacity(0.15))
                    }
                }
                .padding()
                .background(Color.parchment.opacity(0.95))
                
                Divider()
                    .background(Color.sermonGold.opacity(0.2))
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Metadata Chip for Date/Context
                        HStack {
                            Label(note.timestamp.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                                .font(SermonFont.caption(size: 13, weight: .black)) // Bold + Heavy
                                .foregroundColor(.charcoal.opacity(0.8)) // Darker ink
                            
                            if note.isLifeApplication {
                                Text("Life Application")
                                    .font(SermonFont.caption(size: 11, weight: .bold))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .foregroundColor(.white)
                                    .background(Color.sermonGoldDark)
                                    .cornerRadius(6)
                            }
                        }
                        .padding(.top, 10)
                        
                        // Large readable body text
                        Text(note.body)
                            .font(SermonFont.serif(size: 24)) // Slightly larger for presentation
                            .foregroundColor(.charcoal)
                            .lineSpacing(12)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Persistent Scriptures Chip List
                        if let verses = note.detectedVerses, !verses.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Divider()
                                    .padding(.vertical, 8)
                                
                                Text("Scripture references")
                                    .font(SermonFont.caption(size: 12, weight: .black))
                                    .foregroundColor(.sermonGoldDark)
                                    .textCase(.uppercase)
                                    .kerning(1.2)
                                
                                FlowLayout(spacing: 10) {
                                    ForEach(verses, id: \.self) { ref in
                                        Text(ref)
                                            .font(SermonFont.body(size: 16, weight: .bold))
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background(Color.white.opacity(0.6))
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color.sermonGold.opacity(0.3), lineWidth: 1)
                                            )
                                    }
                                }
                            }
                            .padding(.top, 20)
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(24)
                }
            }
        }
        .statusBarHidden()
    }
}

// Senior-grade FlowLayout using the Layout protocol (iOS 16+)
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        var width: CGFloat = 0
        var height: CGFloat = 0
        var currentRowWidth: CGFloat = 0
        var currentRowHeight: CGFloat = 0
        
        for size in sizes {
            if currentRowWidth + spacing + size.width > (proposal.width ?? .infinity) {
                width = max(width, currentRowWidth)
                height += currentRowHeight + (height > 0 ? spacing : 0)
                currentRowWidth = size.width
                currentRowHeight = size.height
            } else {
                currentRowWidth += (currentRowWidth == 0 ? 0 : spacing) + size.width
                currentRowHeight = max(currentRowHeight, size.height)
            }
        }
        width = max(width, currentRowWidth)
        height += (height > 0 && currentRowHeight > 0 ? spacing : 0) + currentRowHeight
        
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        var x = bounds.minX
        var y = bounds.minY
        var currentRowHeight: CGFloat = 0
        
        for index in subviews.indices {
            let size = sizes[index]
            if x + size.width > bounds.maxX && x > bounds.minX {
                x = bounds.minX
                y += currentRowHeight + spacing
                currentRowHeight = 0
            }
            subviews[index].place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            currentRowHeight = max(currentRowHeight, size.height)
        }
    }
}

#Preview {
    PresentationModeView(note: SermonNote(title: "The Prodigal Son", body: "1. The rebellion: He asked for his inheritance early.\n2. The ruin: He spent it all on wild living.\n3. The return: He decided to go home as a servant.\n4. The restoration: The father ran to meet him.", timestamp: Date(), isLifeApplication: true, detectedVerses: ["Luke 15:11-32"]))
}
