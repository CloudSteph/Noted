//
//  ViewController.swift
//  Noted
//
//  Created by Stephanie Liew on 8/8/22.
//

import UIKit
import CloudKit

class SecretDetailViewController: UIViewController, Storyboardable {
    @IBOutlet private(set) weak var secretView: UIView!
    @IBOutlet private(set) weak var secretLabel: UILabel!
    
    private let viewModel: NoteVM = .init()

    public var secretPassedNote: ListNote?
    
    //Creates Blur Effect 
    lazy var blurredView: UIView = {
        let containerView = UIView()
        let blurEffect = UIBlurEffect(style: .dark)
        let dimmedView = UIView()
        dimmedView.backgroundColor = .black.withAlphaComponent(0.6)
        dimmedView.frame = self.view.bounds
        containerView.addSubview(dimmedView)
        return containerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupObservers()
        secretLabel.text = secretPassedNote?.secret ?? ""
       
    }
}


// MARK: - Setup Methods
extension SecretDetailViewController {
    func setupView() {
        view.addSubview(blurredView)
        view.sendSubviewToBack(blurredView)
    }
    
    func setupObservers() {
        NotificationCenter.default.addObserver(forName: .noteEdited, object: .none, queue: .none) { _ in
            guard let id = self.secretPassedNote?.id else { return }
            self.viewModel.retrieveSecret(for: id) { updatedNote in
                DispatchQueue.main.async {
                    self.secretLabel.text = updatedNote?.secret
                }
            }
        }
    }
}

// MARK: - IBActions
extension SecretDetailViewController {
    @IBAction func didCancel(sender: UIButton) {
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
