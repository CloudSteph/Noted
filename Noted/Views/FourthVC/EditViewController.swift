//
//  CreateViewController.swift
//  Noted
//
//  Created by Stephanie Liew on 8/19/22.
//

import Foundation
import UIKit

final class EditViewController: UIViewController, Storyboardable {
    @IBOutlet private(set) weak var editTitleTextField: UITextField!
    @IBOutlet private(set) weak var editNoteTextView: UITextView!
    
    private var viewModel: NoteViewModel = .init()
    var myNote: ((ListNote) -> Void)?
    public var editPassedNote: ListNote?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editTitleTextField.text = editPassedNote?.title ?? ""
        editNoteTextView.text = editPassedNote?.descr ?? ""
        editNoteTextView.layer.cornerRadius = 5
        view.backgroundColor = editPassedNote?.color

        self.navigationController?.navigationBar.tintColor = .black
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel(sender:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDone(sender:)))
    }
}

extension EditViewController {
    @objc private func didTapCancel(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapDone(sender: UIBarButtonItem) {
        guard let unwrappedNote = editPassedNote else { return }
        let updatedNote: ListNote = .init(id: unwrappedNote.id,
                                          title: editTitleTextField.text ?? unwrappedNote.title,
                                          descr: editNoteTextView.text ?? unwrappedNote.descr,
                                          date: unwrappedNote.date,
                                          secret: unwrappedNote.secret,
                                          secretHidden: true,
                                          color: unwrappedNote.color)
        viewModel.update(note: updatedNote)
        self.dismiss(animated: true)
    }
}
