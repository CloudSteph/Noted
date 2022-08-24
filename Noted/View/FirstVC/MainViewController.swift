//
//  MainViewController.swift
//  Noted
//
//  Created by Stephanie Liew on 8/9/22.
//

import Foundation
import UIKit

final class MainViewController: UIViewController, Storyboadable {
    
    @IBOutlet private(set) weak var tableView: UITableView!
    private let searchController = UISearchController()
    private var viewModel: NoteVM = .init()
    private let cellSpacingHeight: CGFloat = 12
    var color: [Int: Colors?] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupObservers()
        setupTableView()
        title = "My Notes"
//        navigationController?.navigationBar.prefersLargeTitles = "My Notes"
        navigationItem.searchController = searchController
        navigationItem.backButtonTitle = ""
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.blue
        
        //remove tableView separator
        tableView.separatorStyle = .none
        
        //Search Controller
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Search Notes..."
        navigationItem.searchController = search
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
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        viewModel.notes.remove(at: indexPath.row)
//        tableView.deleteRows(at: [indexPath], with: .fade)
//            }
//    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return cellSpacingHeight
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if isFiltering {
//            return viewModel.availableNotes.count
//          }
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

// MARK: - SearchBar
extension MainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        print(text)
    }
}

//// MARK: - FilterNotes
//extension MainViewController {
//    var isFiltering: Bool {
//      return searchController.isActive && !isSearchBarEmpty
//    }
//    var isSearchBarEmpty: Bool {
//      return searchController.searchBar.text?.isEmpty ?? true
//    }
//
//    func filterContentForSearchText(_ searchText: String,
//                                    category: ListNote.Category? = nil) {
//        filterNotes = viewModel.availableNotes.filter { (note: note) -> Bool in
//        return notes.name.lowercased().contains(searchText.lowercased())
//      }
//}

