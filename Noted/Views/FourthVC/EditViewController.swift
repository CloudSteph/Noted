//
//  CreateViewController.swift
//  Noted
//
//  Created by Stephanie Liew on 8/19/22.
//

import Foundation
import UIKit

final class EditViewController: UIViewController, Storyboardable {
    @IBOutlet private(set) weak var editTitleTF: UITextField!
    @IBOutlet private(set) weak var editNoteTV: UITextView!
    
    private var viewModel: NoteVM = .init()
    var myNote: ((ListNote) -> Void)?
    public var editPassedNote: ListNote?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editTitleTF.text = editPassedNote?.title ?? ""
        editNoteTV.text = editPassedNote?.descr ?? ""
        
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
                                          title: editTitleTF.text ?? unwrappedNote.title,
                                          descr: editNoteTV.text ?? unwrappedNote.descr,
                                          date: unwrappedNote.date,
                                          secret: unwrappedNote.secret,
                                          secretHidden: true)
        viewModel.update(note: updatedNote)
        self.dismiss(animated: true)
    }
}
