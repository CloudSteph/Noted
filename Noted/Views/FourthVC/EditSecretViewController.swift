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
    
    @IBOutlet private(set) weak var cancelButton: UIButton!
    @IBOutlet private(set) weak var displayButton: UIButton!
    
    private var viewModel: NoteViewModel = .init()
    var displayNote: ((ListNote) -> Void)?
    public var editSecretPassedNote: ListNote?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editSecretTextView.text = editSecretPassedNote?.secret ?? ""
        editSecretTextView.layer.cornerRadius = 5
        editSecretTextView.font = UIFont.systemFont(ofSize: 20)
        cancelButton.backgroundColor = editSecretPassedNote?.color
        displayButton.backgroundColor = editSecretPassedNote?.color
        
    }
}

// MARK: - IBAction
extension EditSecretViewController {
    @IBAction func didTapDisplay(sender: UIButton) {
        guard let unwrappedSecretNote = editSecretPassedNote else { return }
        let updatedSecretNote: ListNote = unwrappedSecretNote.setSecret(editSecretTextView.text)
        let visibleNote = updatedSecretNote.setSecretHidden(false)
        displayNote?(visibleNote)
        
        self.dismiss(animated: true)
    }
    
    @IBAction func didTapCancel(sender: UIButton) {
        dismiss(animated: true)
    }
}
