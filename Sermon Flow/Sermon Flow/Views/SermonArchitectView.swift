
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
        ZStack {
                Color.parchment.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    if !generationComplete {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Sermon Architect")
                                .font(SermonFont.title(size: 28))
                                .foregroundColor(.charcoal)
                            
                            Text("Transform a single topic into a structured sermon outline with AI intelligence.")
                                .font(SermonFont.body(size: 16))
                                .foregroundColor(.charcoal.opacity(0.6))
                        }
                        .padding(.horizontal)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                        
                        TextField("Enter topic (e.g. Grace)", text: $topic)
                            .padding(20)
                            .background(Color.white.opacity(0.6)) // Normalized contrast
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 3) // Standardized shadow
                            .padding(.horizontal)
                            .transition(.opacity)
                        
                        Button(action: {
                            if !purchaseManager.isSubscribed {
                                withAnimation(.spring()) {
                                    showPaywall = true
                                }
                            } else {
                                withAnimation(.spring()) {
                                    showingDisclosure = true
                                }
                            }
                        }) {
                            Text("Generate Outline")
                                .font(SermonFont.body(size: 18, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(topic.isEmpty ? Color.charcoal.opacity(0.1) : Color.sermonGoldDark)
                                .foregroundColor(topic.isEmpty ? .charcoal.opacity(0.3) : .white)
                                .cornerRadius(16)
                        }
                        .buttonStyle(PressedButtonStyle())
                        .disabled(topic.isEmpty || isGenerating)
                        .padding(.horizontal)
                        .transition(.opacity)
                        
                        if isGenerating {
                            VStack(spacing: 20) {
                                ProgressView()
                                    .scaleEffect(1.2)
                                    .tint(.sermonGoldDark)
                                Text("Nexus Core is architecting...")
                                    .font(SermonFont.caption(size: 14, weight: .semibold))
                                    .foregroundColor(.sermonGoldDark.opacity(0.7))
                            }
                            .padding(.top, 20)
                            .transition(.opacity.combined(with: .scale(scale: 0.9)))
                        }
                    } else {
                        // Result View
                        ScrollView {
                            VStack(alignment: .leading, spacing: 24) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Architected Outline")
                                        .font(SermonFont.caption(size: 12, weight: .bold))
                                        .foregroundColor(.sermonGoldDark)
                                        .textCase(.uppercase)
                                        .kerning(1.5)
                                    
                                    Text(topic)
                                        .font(SermonFont.title(size: 32))
                                        .foregroundColor(.charcoal)
                                }
                                
                                CardSection(title: "Overview") {
                                    Text("Faithful reflections on the grace of the prodigal son and the father's heart.")
                                        .font(SermonFont.body(size: 18))
                                        .italic()
                                        .foregroundColor(.charcoal.opacity(0.8))
                                        .padding(.vertical, 4)
                                }
                                
                                CardSection(title: "Theological Structure") {
                                    VStack(alignment: .leading, spacing: 16) {
                                        let points = [
                                            "I. The Departure: A Heart Seeking Autonomy",
                                            "II. The Descent: The Reality of Exile",
                                            "III. The Return: Grace Before Conversion",
                                            "IV. The Restoration: A Father's Extravagant Love"
                                        ]
                                        
                                        ForEach(points, id: \.self) { point in
                                            HStack(alignment: .top, spacing: 12) {
                                                Image(systemName: "sparkles")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.sermonGoldDark)
                                                    .padding(.top, 4)
                                                Text(point)
                                                    .font(SermonFont.body(size: 16, weight: .medium))
                                                    .foregroundColor(.charcoal)
                                            }
                                        }
                                    }
                                }
                                
                                HStack {
                                    Button(action: { showingReport = true }) {
                                        Label("Report Hallucination", systemImage: "flag.fill")
                                            .font(SermonFont.caption(size: 12, weight: .semibold))
                                            .foregroundColor(.red.opacity(0.7))
                                    }
                                    Spacer()
                                    Button(action: {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                            generationComplete = false
                                            topic = ""
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: "arrow.counterclockwise")
                                            Text("Start Over")
                                        }
                                        .font(SermonFont.caption(size: 13, weight: .bold))
                                        .foregroundColor(.charcoal.opacity(0.6))
                                    }
                                }
                                .padding(.top, 10)
                            }
                            .padding(20)
                        }
                        .transition(.asymmetric(insertion: .opacity.combined(with: .move(edge: .bottom)), removal: .opacity))
                    }
                    
                    Spacer()
                }
                .padding(.top, 20)
                .animation(.spring(response: 0.5, dampingFraction: 0.85), value: generationComplete)
                .animation(.spring(), value: isGenerating)
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("Sermon Architect")
                                .font(SermonFont.serif(size: 18, weight: .bold))
                                .foregroundColor(.charcoal)
                        }
                        
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
                
                Text("Architected by Sermon Flow Journal AI. Please verify with Scripture.")
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
