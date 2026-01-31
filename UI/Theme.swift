import SwiftUI

extension Color {
    static let parchment = Color(red: 0.96, green: 0.96, blue: 0.86) // #F5F5DC
    static let charcoal = Color(red: 0.18, green: 0.18, blue: 0.18)  // #2F2F2F
    static let sermonGold = Color(red: 0.83, green: 0.69, blue: 0.22) // Gold
}

struct SermonFont {
    static func serif(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return .custom("Georgia", size: size).weight(weight)
    }
    
    static func title(size: CGFloat = 24) -> Font {
        return serif(size: size, weight: .bold)
    }
    
    static func body(size: CGFloat = 18) -> Font {
        return serif(size: size)
    }
    
    static func caption(size: CGFloat = 14) -> Font {
        return serif(size: size).italic()
    }
}

struct AppTheme {
    static let background = Color.parchment
    static let text = Color.charcoal
}
