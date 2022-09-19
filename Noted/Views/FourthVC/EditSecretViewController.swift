//
//  EditSecretController.swift
//  Noted
//
//  Created by Stephanie Liew on 8/26/22.
//

import Foundation
import UIKit

final class EditSecretViewController: UIViewController, Storyboardable {
    @IBOutlet private(set) weak var editSecretView: UIView!
    @IBOutlet private(set) weak var editSecretTextView: UITextView!
    
    var displayNote: ((ListNote) -> Void)?
    public var editSecretPassedNote: ListNote?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editSecretTextView.text = editSecretPassedNote?.secret ?? ""
    }
}

// MARK: - IBAction
extension EditSecretViewController {
    @IBAction func didTapDisplay(sender: UIButton) {
        guard let unwrappedSecretNote = editSecretPassedNote else { return }
        let updatedNote: ListNote = unwrappedSecretNote.setSecret(editSecretTextView.text)
        let visibleNote = updatedNote.setSecretHidden(false)
        displayNote?(visibleNote)
        self.dismiss(animated: true)
    }
    
    @IBAction func didTapCancel(sender: UIButton) {
        dismiss(animated: true)
    }
}
