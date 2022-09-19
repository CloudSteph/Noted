//
//  MainViewController.swift
//  Noted
//
//  Created by Stephanie Liew on 8/9/22.
//

import Foundation
import UIKit

final class MainViewController: UIViewController, Storyboardable {
    
    @IBOutlet private(set) weak var tableView: UITableView!
    @IBOutlet private(set) weak var searchBar: UISearchBar!
    
    private var viewModel: NoteVM = .init()
    private let cellSpacingHeight: CGFloat = 12
    var color: [Int: Colors?] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupObservers()
        setupTableView()
        title = "My Notes"
        navigationItem.backButtonTitle = ""
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.blue
        
        //remove tableView separator
        tableView.separatorStyle = .none
        
        //Search Controller
        searchBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
}

// MARK: - Setup Methods
extension MainViewController {
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(forName: .noteDeleted, object: .none, queue: .none) { _ in
            self.viewModel.refreshNotes {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: .noteEdited, object: .none, queue: .none) { _ in
            self.viewModel.refreshNotes {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detailVC: DetailViewController = .instantiate()
        detailVC.passedNote = viewModel.note(for: indexPath.row)
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.noteCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.identifer, for: indexPath) as? TableViewCell else {
            return .init()
        }
        
        cell.configure(with: viewModel.note(for: indexPath.row), indexPath: indexPath)
        cell.view.layer.cornerRadius = cell.view.frame.height / 5
        return cell
    }
}

// MARK: - UISearchBarDelegate
extension MainViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("### searchText: \(searchText)")
        self.viewModel.setFilterNotes(for: searchText)
        self.tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.viewModel.isSearching = true
        self.tableView.reloadData()
        print("### Start editing")
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        self.viewModel.isSearching = false
        return true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.tableView.reloadData()
        self.viewModel.isSearching = false
        print("### End editing")
    }
}

// MARK: - IBAction
extension MainViewController {
    @IBAction func didTapAdd(sender: UIBarButtonItem) {
        let createVC: CreateViewController = .instantiate()
        createVC.myNote = { [weak self] note in
            self?.viewModel.save(note: note)
        }
        self.navigationController?.pushViewController(createVC, animated: true)
    }
}
