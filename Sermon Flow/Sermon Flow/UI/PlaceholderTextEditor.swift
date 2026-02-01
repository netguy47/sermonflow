import SwiftUI

struct PlaceholderTextEditor<Value: Hashable>: View {
    let placeholder: String
    @Binding var text: String
    @FocusState.Binding var focusedField: Value?
    let equals: Value
    
    private var isEffectivelyFocused: Bool {
        focusedField == equals
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(SermonFont.body())
                    .foregroundColor(.gray.opacity(0.6))
                    .padding(.top, 8)
                    .padding(.leading, 5)
            }
            
            TextEditor(text: $text)
                .font(SermonFont.body())
                .foregroundColor(.charcoal)
                .scrollContentBackground(.hidden)
                .focused($focusedField, equals: equals)
                .lineSpacing(4)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.4))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isEffectivelyFocused ? Color.sermonGold.opacity(0.5) : Color.clear, lineWidth: 2)
        )
        .shadow(color: isEffectivelyFocused ? Color.sermonGold.opacity(0.1) : Color.clear, radius: 10)
        .animation(.easeInOut(duration: 0.2), value: isEffectivelyFocused)
    }
}
