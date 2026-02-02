import SwiftUI

struct OnboardingView: View {
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Premium Logo/Icon Identity
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.sermonGold.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.sermonGold)
                        .shadow(color: .sermonGold.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                
                VStack(spacing: 8) {
                    Text("Sermon Flow Journal")
                        .font(SermonFont.serif(size: 32, weight: .black))
                        .foregroundColor(.charcoal)
                    
                    Text("Capture the Word. Transform Your Life.")
                        .font(SermonFont.body(size: 16))
                        .foregroundColor(.charcoal.opacity(0.8)) // Darkened from 0.6
                        .italic()
                }
            }
            
            // Feature Pillars
            VStack(alignment: .leading, spacing: 20) {
                FeatureRow(icon: "sparkles", title: "Sermon Architect", description: "Turn a single topic into a full outline.")
                FeatureRow(icon: "hand.tap", title: "Smart Scripture", description: "Type references to see verses instantly.")
                FeatureRow(icon: "star", title: "Life Application", description: "Flag key takeaways for Monday's recall.")
            }
            .padding(.horizontal, 32)
            
            Spacer()
            
            VStack(spacing: 16) {
                Text("Your first note is waiting...")
                    .font(SermonFont.caption(size: 14, weight: .black)) // Bold + Dark
                    .foregroundColor(.charcoal.opacity(0.7)) // Darkened from 0.4
                
                Text("( Tap + to Begin )")
                    .font(SermonFont.body(size: 18, weight: .black)) // Extra Bold
                    .foregroundColor(.sermonGoldDark)
                    .padding(.bottom, 40)
            }
        }
        .background(Color.parchment.ignoresSafeArea())
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.sermonGoldDark)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(SermonFont.body(size: 16, weight: .bold))
                    .foregroundColor(.charcoal)
                Text(description)
                    .font(SermonFont.caption(size: 13))
                    .foregroundColor(.charcoal.opacity(0.8)) // Darkened from 0.5
            }
        }
    }
}

#Preview {
    OnboardingView()
}
