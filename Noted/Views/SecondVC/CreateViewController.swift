//
//  DetailViewController.swift
//  Noted
//
//  Created by Stephanie Liew on 8/9/22.
//

import Foundation
import UIKit

// AddNoteViewController
// - creating a note only

protocol MyNoteProtocol: AnyObject {
    func myNote(note: ListNote)
}

final class CreateViewController: UIViewController, Storyboardable {
    @IBOutlet private(set) weak var titleTextField: UITextField!
    @IBOutlet private(set) weak var descrTextView: UITextView!
    
    private var viewModel: NoteVM = .init()
    var myNote: ((ListNote) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descrTextView.text = "New notes..."
        descrTextView.textColor = UIColor.lightGray
        descrTextView.returnKeyType = .done
        descrTextView.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didTapSave(sender:)))
    }
}

// MARK: - UITextViewDelegate
extension CreateViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return true
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "New Notes..."
            textView.textColor = .lightGray
        }
    }
}

// MARK: - IBAction
extension CreateViewController {
    @objc func didTapSave(sender: UIBarButtonItem){
        guard let unwrapTitleText = titleTextField.text else {
            print("Title Missing Error")
            return
        }

        guard let unwrapNoteText = descrTextView.text else {
            print("Note Missing Error")
            return
        }
        
        let newNote = ListNote(id: UUID(),
                               title: unwrapTitleText,
                               descr: unwrapNoteText,
                               date: Date(),
                               secret: "",
                               secretHidden: true)
        myNote?(newNote)
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
