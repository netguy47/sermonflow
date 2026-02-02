import SwiftUI

extension Color {
    static let parchment = Color(red: 0.96, green: 0.96, blue: 0.86) // #F5F5DC
    static let charcoal = Color(red: 0.07, green: 0.07, blue: 0.07)  // #121212 - Deep Ink Black
    static let sermonGold = Color(red: 0.83, green: 0.69, blue: 0.22) // Gold
    static let sermonGoldDark = Color(red: 0.65, green: 0.53, blue: 0.15) // Darker Gold for contrast
}

struct SermonFont {
    static func serif(size: CGFloat, weight: Font.Weight = .regular, relativeTo: Font.TextStyle = .body) -> Font {
        return .custom("Georgia", size: size, relativeTo: relativeTo).weight(weight)
    }
    
    static func title(size: CGFloat = 24, weight: Font.Weight = .bold) -> Font {
        return serif(size: size, weight: weight, relativeTo: .title)
    }
    
    static func body(size: CGFloat = 18, weight: Font.Weight = .regular) -> Font {
        return serif(size: size, weight: weight, relativeTo: .body)
    }
    
    static func caption(size: CGFloat = 14, weight: Font.Weight = .regular) -> Font {
        return serif(size: size, weight: weight, relativeTo: .caption).italic()
    }
}

struct AppTheme {
    static let background = Color.parchment
    static let text = Color.charcoal
}
