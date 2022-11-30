//
//  Colors.swift
//  Noted
//
//  Created by Stephanie Liew on 8/22/22.
//

import Foundation
import UIKit

enum Colors {
    static let blue: UIColor = .init(red: 0.15, green: 0.48, blue: 0.75, alpha: 1.00)
    static let green: UIColor = .init(red: 0.69, green: 0.84, blue: 0.71, alpha: 1.00)
    static let orange: UIColor = .init(red: 1.00, green: 0.76, blue: 0.38, alpha: 1.00)
    static let purple: UIColor = .init(red: 0.69, green: 0.71, blue: 1.00, alpha: 1.00)
    static let teal: UIColor = .init(red: 0.40, green: 0.75, blue: 0.75, alpha: 1.00)
    static let peach: UIColor = .init(red: 0.94, green: 0.62, blue: 0.62, alpha: 1.00)
}

extension UIColor {
    //initalization; remove new lines and whitespaces and # if present
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        //Declare Helper variables
        //First variable will store the hexadecimal value as an unsigned integer; declare rbg and alpha value
        var rgb: UInt32 = 0
        var r: CGFloat = 0
        var b: CGFloat = 0
        var g: CGFloat = 0
        var a: CGFloat = 1
        let length = hexSanitized.count //stores the length of the sanitized string for convenience
        
        //Create Scanner; scan string for unsigned value
        guard Scanner(string: hexSanitized).scanHexInt32(&rgb) else  { return nil }
        
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
            
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
            
        } else {
            return nil
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
    
    // Convience Methods
    var toHex: String? {
            // Extract Components
            guard let components = cgColor.components, components.count >= 3 else {
                return nil
            }

            // Helpers
            let r = Float(components[0])
            let g = Float(components[1])
            let b = Float(components[2])
            var a = Float(1.0)

            if components.count >= 4 {
                a = Float(components[3])
            }

            // Create Hex String
            let hex = String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))

            return hex
        }
}
