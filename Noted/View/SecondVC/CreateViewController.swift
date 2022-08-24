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

final class CreateViewController: UIViewController, Storyboadable {
    @IBOutlet private(set) weak var titleTextField: UITextField!
    @IBOutlet private(set) weak var descrTextView: UITextView!
    
    private var viewModel: NoteVM = .init()
    var myNote: ((ListNote) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descrTextView.text = "New notes..."
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didTapSave(sender:)))
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
        
        let newNote = ListNote(id: UUID(), title: unwrapTitleText, descr: unwrapNoteText, date: Date())
        myNote?(newNote)
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

//// MARK: - Placeholder
//extension CreateViewController {
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        if textView.textColor == UIColor.lightGray {
//            textView.text = nil
//            textView.textColor = UIColor.black
//        }
//    }
//
//    func textViewDidEndEditing(_ textView: UITextView) {
//        if textView.text.isEmpty {
//            textView.text = "Placeholder"
//            textView.textColor = UIColor.lightGray
//        }
//    }
//
//}

