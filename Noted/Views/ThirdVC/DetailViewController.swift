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

final class DetailViewController: UIViewController, Storyboardable {
    @IBOutlet private(set) weak var detailTitleLabel: UILabel!
    @IBOutlet private(set) weak var detailNoteLabel: UILabel!
    
    private var viewModel: NoteViewModel = .init()
    public var passedNote: ListNote?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDetailObservers()
        setupNavigationBar()
        detailTitleLabel.text = passedNote?.title ?? ""
        detailNoteLabel.text = passedNote?.descr ?? ""
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedNote(sender:)))
        tap.numberOfTapsRequired = viewModel.tapsRequired()
        view.addGestureRecognizer(tap)

        view.backgroundColor = passedNote?.color
        
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

// MARK: - Setup Methods
extension DetailViewController {
    func setupDetailObservers() {
        NotificationCenter.default.addObserver(forName: .noteEdited, object: .none, queue: .none) { notif in
            guard let data = notif.object as? ListNote else { return }
            DispatchQueue.main.async {
                self.detailTitleLabel.text = data.title
                self.detailNoteLabel.text = data.descr
            }
        }
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
    
    @objc private func tappedNote(sender: UITextView) {
        print("Did Double Tapped")
        let secretDetailVC: SecretNoteViewController = .instantiate()
        secretDetailVC.secretPassedNote = passedNote
        secretDetailVC.modalPresentationStyle = .overCurrentContext
        secretDetailVC.modalTransitionStyle = .crossDissolve
        present(secretDetailVC, animated: true)
    }
}
