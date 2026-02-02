import SwiftUI
import StoreKit

struct SettingsView: View {
    @StateObject private var purchaseManager = PurchaseManager.shared
    @State private var showPaywall = false
    
    var body: some View {
        List {
            Section(header: Text("SermonFlow Pro")
                .font(SermonFont.serif(size: 13, weight: .bold))
                .foregroundColor(.sermonGoldDark)
                .textCase(.uppercase)
                .kerning(1.2)) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(purchaseManager.isSubscribed ? "Pro Active" : "Unlock Pro")
                            .font(SermonFont.body(size: 16, weight: .semibold))
                            .foregroundColor(purchaseManager.isSubscribed ? .sermonGoldDark : .charcoal)
                        
                        Text(purchaseManager.isSubscribed ? "Thank you for your support!" : "Unlimited presentations & more.")
                            .font(SermonFont.caption())
                            .foregroundColor(.charcoal.opacity(0.8)) // Darkened from 0.5
                    }
                    
                    Spacer()
                    
                    if !purchaseManager.isSubscribed {
                        Button(action: { 
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                showPaywall = true 
                            }
                        }) {
                            Text("Upgrade")
                                .font(SermonFont.caption(size: 12, weight: .bold))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.sermonGold)
                                .foregroundColor(.white)
                                .cornerRadius(20)
                        }
                        .buttonStyle(BouncyButtonStyle())
                    } else {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.sermonGoldDark)
                    }
                }
            }
            
            Section(header: Text("Information")
                .font(SermonFont.serif(size: 13, weight: .bold))
                .foregroundColor(.charcoal.opacity(0.75)) // Improved header contrast
                .textCase(.uppercase)
                .kerning(1.2)) {
                
                ReminderToggleRow()
                
                NavigationLink(destination: PrivacyPolicyView()) {
                    Text("Privacy Policy")
                        .font(SermonFont.body(size: 16))
                }
                
                NavigationLink(destination: ScriptureCreditsView()) {
                    Text("Scripture Credits")
                        .font(SermonFont.body(size: 16))
                }
            }
            
            Section(header: Text("App Info")
                .font(SermonFont.serif(size: 13, weight: .bold))
                .foregroundColor(.charcoal.opacity(0.75)) // Improved header contrast
                .textCase(.uppercase)
                .kerning(1.2)) {
                HStack {
                    Text("Version")
                        .font(SermonFont.body(size: 16))
                    Spacer()
                    Text("1.0.0")
                        .font(SermonFont.caption())
                        .foregroundColor(.gray)
                }
            }
        }
        .navigationTitle("Settings")
        .background(Color.parchment.ignoresSafeArea())
        .scrollContentBackground(.hidden)
        .sheet(isPresented: $showPaywall) {
            SubscriptionStoreView(groupID: "SF_PREMIUM_GROUP")
                .subscriptionStoreControlStyle(.picker)
        }
    }
}

struct ReminderToggleRow: View {
    @AppStorage("mondayRecallEnabled") private var mondayRecallEnabled = true
    
    var body: some View {
        Toggle(isOn: $mondayRecallEnabled) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Monday Recall")
                    .font(SermonFont.body(size: 16, weight: .semibold))
                    .foregroundColor(.charcoal)
                Text("Morning reflection on your life application.")
                    .font(SermonFont.caption())
                    .foregroundColor(.charcoal.opacity(0.7)) // Improved secondary contrast
            }
        }
        .tint(.sermonGoldDark)
        .onChange(of: mondayRecallEnabled) { oldValue, newValue in
            if newValue {
                NotificationManager.shared.requestAuthorization()
            } else {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["MondayRecall"])
            }
        }
    }
}

struct BouncyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy Policy")
                    .font(SermonFont.title())
                
                Text("Sermon Flow is designed with your privacy in mind. All your notes are stored securely in Firebase Firestore. We use Anonymous Authentication to ensure that your data is private to your device while still allowing for cloud backup and offline persistence.")
                    .font(SermonFont.body())
                
                Text("We do not collect any personal information, and your notes are only accessible by you.")
                    .font(SermonFont.body())
            }
            .padding()
        }
        .background(Color.parchment.ignoresSafeArea())
    }
}

struct ScriptureCreditsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Scripture Credits")
                    .font(SermonFont.title())
                
                Text("Scripture quotations are from the World English Bible (WEB), which is in the public domain.")
                    .font(SermonFont.body())
                
                Link("Learn more about the World English Bible", destination: URL(string: "https://worldenglish.bible")!)
                    .font(SermonFont.body())
                    .foregroundColor(.sermonGold)
            }
            .padding()
        }
        .background(Color.parchment.ignoresSafeArea())
    }
}

#Preview {
    NavigationView {
        SettingsView()
    }
}
