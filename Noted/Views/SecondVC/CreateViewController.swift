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

final class CreateViewController: UIViewController, Storyboardable {
    @IBOutlet private(set) weak var titleTextField: UITextField!
    @IBOutlet private(set) weak var descrTextView: UITextView!
    
    private var viewModel: NoteViewModel = .init()
    var myNote: ((ListNote) -> Void)?
    
    private let creationColors: [UIColor] = [Colors.blue, Colors.green, Colors.purple, Colors.orange, Colors.teal, Colors.peach]

    override func viewDidLoad() {
        super.viewDidLoad()
        descrTextView.text = "New notes..."
        descrTextView.textColor = UIColor.lightGray
        descrTextView.returnKeyType = .done
        descrTextView.delegate = self
        descrTextView.layer.cornerRadius = 5
        view.backgroundColor = .systemGray6
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didTapSave(sender:)))
        navigationItem.rightBarButtonItem?.tintColor = .black
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
                               secretHidden: true,
                               color: creationColors.randomElement() ?? Colors.peach)
        myNote?(newNote)
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
