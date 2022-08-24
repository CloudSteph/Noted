//
//  EditViewController.swift
//  Noted
//
//  Created by Stephanie Liew on 8/15/22.
//

// DetailViewController
// - Showing detail, no editing allowed here


import Foundation
import UIKit

final class DetailViewController: UIViewController, Storyboadable {
    @IBOutlet private(set) weak var detailTitleLabel: UILabel!
    @IBOutlet private(set) weak var detailNoteLabel: UILabel!
    
    private var viewModel: NoteVM = .init()
    public var passedNote: ListNote?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        detailTitleLabel.text = passedNote?.title ?? ""
        detailNoteLabel.text = passedNote?.descr ?? ""
        self.navigationItem.backButtonTitle = ""
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped(sender:)))
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
    }
}

// MARK: - Helper Methods
extension DetailViewController {
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                image: UIImage(systemName: "trash"),
                style: .done,
                target: self,
                action: #selector(deleteButtonPressed(sender:))),
            UIBarButtonItem(
                image: UIImage(systemName: "square.and.pencil"),
                style: .plain,
                target: self,
                action: #selector(editButtonPressed(sender:)))
        ]
    }
}

// MARK: - IBActions
extension DetailViewController {
    @objc private func editButtonPressed(sender: UIBarButtonItem) {
        print("Edit Button Pressed!")
        let editVC: EditViewController = .instantiate()
        editVC.myNote = { [weak self] note in
            self?.viewModel.save(note: note)
        }
        editVC.editPassedNote = passedNote
        let editNav: UINavigationController = .init(rootViewController: editVC)
        self.present(editNav, animated: true)
    }
    
    @objc private func deleteButtonPressed(sender: UIBarButtonItem) {
        print("Delete Button Pressed!")
        guard let unwrappedNote = passedNote else { return }
        viewModel.delete(note: unwrappedNote)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func doubleTapped(sender: UITextView) {
        print("Did Double Tapped")
        let secretVC: SecretNoteViewController = .instantiate()
                secretVC.modalPresentationStyle = .overCurrentContext
                secretVC.modalTransitionStyle = .crossDissolve
                present(secretVC, animated: true)
    }
}
