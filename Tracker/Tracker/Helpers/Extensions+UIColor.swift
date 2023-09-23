//
//  Extensions+UIColor.swift
//  Tracker
//
//  Created by Тимур Танеев on 07.08.2023.
//

import UIKit

extension UIColor {
    static let ypBackgroundDay = UIColor(named: "ypBackgroundDay")!
    static let ypBlackDay = UIColor(named: "ypBlackDay")!
    static let ypBlue = UIColor(named: "ypBlue")!
    static let ypGray = UIColor(named: "ypGray")!
    static let ypRed = UIColor(named: "ypRed")!
    static let ypWhiteDay = UIColor(named: "ypWhiteDay")!
    static let ypGradientColor1 = UIColor(named: "ypGradientColor1")!
    static let ypGradientColor2 = UIColor(named: "ypGradientColor2")!
    static let ypGradientColor3 = UIColor(named: "ypGradientColor3")!

    enum YpColors: String, CaseIterable {
        case ypColorSelection1 = "ypColorSelection-1"
        case ypColorSelection2 = "ypColorSelection-2"
        case ypColorSelection3 =  "ypColorSelection-3"
        case ypColorSelection4 =  "ypColorSelection-4"
        case ypColorSelection5 =  "ypColorSelection-5"
        case ypColorSelection6 =  "ypColorSelection-6"
        case ypColorSelection7 =  "ypColorSelection-7"
        case ypColorSelection8 =  "ypColorSelection-8"
        case ypColorSelection9 =  "ypColorSelection-9"
        case ypColorSelection10 = "ypColorSelection-10"
        case ypColorSelection11 = "ypColorSelection-11"
        case ypColorSelection12 = "ypColorSelection-12"
        case ypColorSelection13 = "ypColorSelection-13"
        case ypColorSelection14 = "ypColorSelection-14"
        case ypColorSelection15 = "ypColorSelection-15"
        case ypColorSelection16 = "ypColorSelection-16"
        case ypColorSelection17 = "ypColorSelection-17"
        case ypColorSelection18 = "ypColorSelection-18"

        static func allColorNames() -> [String] {
            return allCases.compactMap { $0.rawValue }
        }

        func color() -> UIColor? {
            return UIColor(named: self.rawValue)
        }
    }
}
