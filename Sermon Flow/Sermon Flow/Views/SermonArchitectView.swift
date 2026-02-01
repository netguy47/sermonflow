
import SwiftUI
import StoreKit

struct SermonArchitectView: View {
    @Binding var selectedTab: Int
    @State private var topic: String = ""
    @State private var showingDisclosure = false
    @State private var isGenerating = false
    @State private var generationComplete = false
    @State private var showingReport = false
    @StateObject private var purchaseManager = PurchaseManager.shared
    @State private var showPaywall = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.parchment.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    if !generationComplete {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Sermon Architect")
                                .font(SermonFont.title())
                                .foregroundColor(.charcoal)
                            
                            Text("Transform a single topic into a structured sermon outline with AI intelligence.")
                                .font(SermonFont.body(size: 16))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        
                        TextField("Enter topic (e.g. Grace)", text: $topic)
                            .padding()
                            .background(Color.white.opacity(0.5))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        
                                Button(action: {
                                    if !purchaseManager.isSubscribed {
                                        showPaywall = true
                                    } else {
                                        showingDisclosure = true
                                    }
                                }) {
                                    Text("Generate Outline")
                                        .font(SermonFont.body(size: 18))
                                        .bold()
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(topic.isEmpty ? Color.gray : Color.sermonGold)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                }
                                .buttonStyle(PressedButtonStyle())
                                .disabled(topic.isEmpty || isGenerating)
                                .padding(.horizontal)
                                
                                if isGenerating {
                                    VStack(spacing: 16) {
                                        ProgressView()
                                            .tint(.sermonGold)
                                        Text("Nexus Core is architecting...")
                                            .font(SermonFont.caption())
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.top)
                                }
                            } else {
                                // Result View
                                ScrollView {
                                    VStack(alignment: .leading, spacing: 20) {
                                        Text(topic)
                                            .font(SermonFont.title())
                                            .foregroundColor(.sermonGold)
                                        
                                        Text("Faithful reflections on the grace of the prodigal son and the father's heart.")
                                            .font(SermonFont.body(size: 18))
                                            .italic()
                                        
                                        Divider()
                                        
                                        Text("I. The Departure: A Heart Seeking Autonomy\nII. The Descent: The Reality of Exile\nIII. The Return: Grace Before Conversion\nIV. The Restoration: A Father's Extravagant Love")
                                            .font(SermonFont.body(size: 16))
                                            .lineSpacing(8)
                                    }
                                    .padding()
                                }
                                
                                HStack {
                                    Button(action: { showingReport = true }) {
                                        Label("Report Content", systemImage: "flag")
                                            .font(SermonFont.caption())
                                            .foregroundColor(.red.opacity(0.8))
                                    }
                                    Spacer()
                                    Button("Start Over") {
                                        generationComplete = false
                                        topic = ""
                                    }
                                    .font(SermonFont.caption())
                                    .foregroundColor(.charcoal)
                                }
                                .padding()
                            }
                            
                            Spacer()
                        }
                        .padding(.top, 40)
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                selectedTab = 0
                            }) {
                                HStack {
                                    Image(systemName: "house.fill")
                                    Text("Home")
                                }
                                .font(.headline)
                                .foregroundColor(.sermonGold)
                            }
                        }
                    }
                    .sheet(isPresented: $showingDisclosure) {
                        AIDisclosureView {
                            startGeneration()
                        }
                    }
                    .sheet(isPresented: $showPaywall) {
                        SubscriptionStoreView(groupID: "SF_PREMIUM_GROUP")
                            .subscriptionStoreControlStyle(.picker)
                    }
                    .alert("Report Content", isPresented: $showingReport) {
                        Button("Reporthallucination", role: .destructive) { }
                        Button("Cancel", role: .cancel) { }
                    } message: {
                        Text("Is this AI-generated content inaccurate or inappropriate?")
                    }
                }
            }
            
            private func startGeneration() {
                isGenerating = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    isGenerating = false
                    generationComplete = true
                }
            }
        }

        struct PressedButtonStyle: ButtonStyle {
            func makeBody(configuration: Configuration) -> some View {
                configuration.label
                    .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
                    .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
            }
        }

struct AIDisclosureView: View {
    var onAccept: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundColor(.sermonGold)
                .padding(.top, 40)
            
            Text("AI Transparency Disclosure")
                .font(SermonFont.title())
                .multilineTextAlignment(.center)
            
            VStack(spacing: 20) {
                Text("Your topics are shared with **Google Gemini** to generate content.")
                    .font(SermonFont.body(size: 16))
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.charcoal.opacity(0.05))
                    .cornerRadius(12)
                
                Text("We are committed to providing advanced AI-driven architecture tools for your ministry while maintaining clear data privacy standards.")
                    .font(SermonFont.caption())
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                
                Text("Architected by SermonFlow AI. Please verify with Scripture.")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.sermonGold.opacity(0.6))
                    .padding(.top, 4)
            }
            .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                dismiss()
                onAccept()
            }) {
                Text("Proceed with Google Gemini")
                    .font(SermonFont.body(size: 18))
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.charcoal)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
        .background(Color.parchment.ignoresSafeArea())
    }
}

#Preview {
    SermonArchitectView(selectedTab: .constant(1))
}
