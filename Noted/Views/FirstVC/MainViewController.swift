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
    
    private var viewModel: NoteViewModel = .init()
    private let cellSpacingHeight: CGFloat = 12
    var color: [Int: Colors?] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupObservers()
        setupTableView()
        title = "My Notes"
        navigationItem.backButtonTitle = ""
        self.navigationController?.navigationBar.tintColor = .black
        
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
    //Adds an entry to the notification center to receive notifications that passed to the provided block
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
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
            -> UISwipeActionsConfiguration? {
                let deleteAction = UIContextualAction(style: .destructive, title: nil) {_,_,_ in
                    self.viewModel.deleteNote(atIndex: indexPath)
                    tableView.deleteRows(at: [indexPath], with: .fade)
            }
                deleteAction.image = UIImage(systemName: "trash")
                deleteAction.backgroundColor = viewModel.note(for: indexPath.row).color
                let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            return configuration
    }
    
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
    //User changed the serach text
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("### searchText: \(searchText)")
        self.viewModel.setFilterNotes(for: searchText)
        self.tableView.reloadData()
    }
    
    //User starts editing the search text
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.viewModel.isSearching = true
        self.tableView.reloadData()
        print("### Start editing")
    }
    
    //Editing should stop in the specified search bar
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        self.viewModel.isSearching = false
        return true
    }
    
    //User finished editing the search text
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.tableView.reloadData()
        self.viewModel.isSearching = false
        print("### End editing")
    }
}

// MARK: - IBAction for creating note
extension MainViewController {
    @IBAction func didTapAdd(sender: UIBarButtonItem) {
        let createVC: CreateViewController = .instantiate()
        createVC.myNote = { [weak self] note in
            self?.viewModel.save(note: note)
        }
        self.navigationController?.pushViewController(createVC, animated: true)
    }
}

// MARK: IBAction to navigate to Settings
extension MainViewController {
    @IBAction func didTapSettings(sender: UIBarButtonItem) {
        let settingVC: SettingsViewController = .instantiate()
        self.navigationController?.pushViewController(settingVC, animated: true)
    }
}
