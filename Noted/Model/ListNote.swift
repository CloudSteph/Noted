//
//  NoteMO.swift
//  Noted
//
//  Created by Stephanie Liew on 8/8/22.
//

import Foundation
import UIKit

// MARK: - Model (Blueprint)
struct ListNote {
    let id: UUID
    let title: String
    let descr: String
    let date: Date
    let secret: String
    let secretHidden: Bool
    let color: UIColor
}

// MARK: - Helper Methods
extension ListNote {
    func setSecret(_ updatedSecret: String) -> ListNote {
        return .init(id: id, title: title, descr: descr, date: date, secret: updatedSecret, secretHidden: secretHidden, color: color)
    }
    
    func setSecretHidden(_ isHidden: Bool) -> ListNote {
        return .init(id: id, title: title, descr: descr, date: date, secret: secret, secretHidden: isHidden, color: color)
    }
}
