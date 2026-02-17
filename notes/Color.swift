//
//  Color.swift
//  notes
//
//  Created by Caleb Chiang on 2026-02-16.
//

import SwiftUI

extension Color {
    
    // HEX → Color
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let r, g, b: UInt64
        (r, g, b) = (
            (int >> 16) & 0xFF,
            (int >> 8) & 0xFF,
            int & 0xFF
        )
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
    
    // Color → HEX
    func toHex() -> String {
        let uiColor = UIColor(self)
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return String(format: "#%02lX%02lX%02lX",
                      Int(r * 255),
                      Int(g * 255),
                      Int(b * 255))
    }
}

