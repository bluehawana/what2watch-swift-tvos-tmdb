import SwiftUI

enum AppTheme {
    static let primary = Color(hex: 0x00A8E1)
    static let secondary = Color(hex: 0x1A98FF)
    static let accent = Color(hex: 0xFF9500)
    static let background = Color(hex: 0x0F171E)
    static let backgroundSecondary = Color(hex: 0x1A242F)
    static let surface = Color(hex: 0x1A242F)
    static let surfaceSecondary = Color(hex: 0x232F3E)
    static let text = Color.white
    static let textSecondary = Color(hex: 0x8D9BA8)
    static let textTertiary = Color(hex: 0x5A6A7A)
    static let border = Color(hex: 0x2A3A4A)
}

extension Color {
    init(hex: Int, alpha: Double = 1) {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}
