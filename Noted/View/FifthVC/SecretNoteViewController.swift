//
//  ViewController.swift
//  Noted
//
//  Created by Stephanie Liew on 8/8/22.
//

import UIKit

class SecretNoteViewController: UIViewController, Storyboadable {
    @IBOutlet private(set) weak var secretView: UIView!
    @IBOutlet private(set) weak var secretTextView: UITextView!
    var myNote: ((ListNote) -> Void)?
    public var secretPassedNote: ListNote?
    
    lazy var blurredView: UIView = {
        // 1. create container view
        let containerView = UIView()
        // 2. create custom blur view
        let blurEffect = UIBlurEffect(style: .dark)
        // 3. create semi-transparent black view
        let dimmedView = UIView()
        dimmedView.backgroundColor = .black.withAlphaComponent(0.6)
        dimmedView.frame = self.view.bounds

        // 4. add both as subviews
        containerView.addSubview(dimmedView)
        return containerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        secretTextView.text = secretTextView?.description ?? ""
    }
}


// MARK: - Setup Method
extension SecretNoteViewController {
    func setupView() {
        // 6. add blur view and send it to back
        view.addSubview(blurredView)
        view.sendSubviewToBack(blurredView)
    
    }
}

