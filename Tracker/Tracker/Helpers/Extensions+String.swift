//
//  Extensions+String.swift
//  Tracker
//
//  Created by Тимур Танеев on 23.09.2023.
//

import Foundation

extension String {
    func localized(comment: String = "") -> String {
        let localizedString = NSLocalizedString(self, comment: comment)
        return localizedString
    }

    func localizedValue(_ value: CVarArg, comment: String = "") -> String {
        String.localizedStringWithFormat(
            NSLocalizedString(self, comment: comment),
            value
        )
    }
}
