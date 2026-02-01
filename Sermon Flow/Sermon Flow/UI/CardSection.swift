import SwiftUI

struct CardSection<Content: View>: View {
    let title: String?
    let content: Content
    
    init(title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title = title {
                Text(title)
                    .font(SermonFont.serif(size: 14, weight: .bold))
                    .foregroundColor(.sermonGoldDark)
                    .padding(.horizontal, 4)
            }
            
            VStack(spacing: 0) {
                content
            }
            .padding()
            .background(Color.white.opacity(0.6))
            .cornerRadius(16)
            .shadow(color: Color.charcoal.opacity(0.04), radius: 8, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.charcoal.opacity(0.05), lineWidth: 1)
            )
        }
        .padding(.horizontal)
    }
}
