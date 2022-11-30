//
//  ViewController.swift
//  Noted
//
//  Created by Stephanie Liew on 8/8/22.
//

import UIKit
import CloudKit

class SecretNoteViewController: UIViewController, Storyboardable {
    @IBOutlet private(set) weak var secretView: UIView!
    @IBOutlet private(set) weak var secretLabel: UILabel!
    
    @IBOutlet private(set) weak var doneButton: UIButton!
    @IBOutlet private(set) weak var editButton: UIButton!
    
    private let viewModel: NoteViewModel = .init()

    public var secretPassedNote: ListNote?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupObservers()
        secretLabel.text = secretPassedNote?.secret ?? ""
        doneButton.backgroundColor = secretPassedNote?.color
        editButton.backgroundColor = secretPassedNote?.color
    }
}


// MARK: - Setup Method
extension SecretNoteViewController {
    func setupObservers() {
        NotificationCenter.default.addObserver(forName: .noteEdited, object: .none, queue: .none) { _ in
            guard let id = self.secretPassedNote?.id else { return }
            self.viewModel.retrieveSecret(for: id) { updatedNote in
                self.secretPassedNote = updatedNote
                DispatchQueue.main.async {
                    self.secretLabel.text = updatedNote?.secret
                }
            }
        }
    }
}

// MARK: - IBActions
extension SecretNoteViewController {
    @IBAction func didPressDone(sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func didTapEdit(sender: UIButton) {
        print("Edit Button pressed!!")
        let editSecretVC: EditSecretViewController = .instantiate()
        editSecretVC.displayNote = { [weak self] note in
            self?.viewModel.update(note: note)
        }
        editSecretVC.editSecretPassedNote = secretPassedNote
        let editSecretNav: UINavigationController = .init(rootViewController: editSecretVC)
        self.present(editSecretNav, animated: true)
    }
}
