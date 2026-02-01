import SwiftUI

struct OnboardingView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "book.pages")
                .font(.system(size: 80))
                .foregroundColor(.sermonGold)
            
            Text("Welcome to Sermon Flow")
                .font(SermonFont.title())
                .foregroundColor(.charcoal)
            
            VStack(spacing: 16) {
                InstructionRow(text: "Tap + to start your first sermon note.")
                InstructionRow(text: "Try typing a verse like John 3:16 to see the magic.")
                InstructionRow(text: "Toggle 'Life Application' to flag key takeaways.")
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding(.top, 60)
        .background(Color.parchment.ignoresSafeArea())
    }
}

struct InstructionRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "hand.tap")
                .foregroundColor(.sermonGold)
            Text(text)
                .font(SermonFont.body(size: 16))
                .foregroundColor(.charcoal.opacity(0.8))
            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
}
