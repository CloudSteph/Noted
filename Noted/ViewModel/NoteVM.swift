//
//  NoteVM.swift
//  Noted
//
//  Created by Stephanie Liew on 8/9/22.
//

import Foundation
import UIKit

extension NSNotification.Name {
    static let noteDeleted: NSNotification.Name = .init(rawValue: "NoteDeleted")
    static let noteEdited: NSNotification.Name = .init(rawValue: "NoteEdited")
}

final class NoteVM {
    
    // Reference to managed object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private(set) var repository: NoteRepository
    private(set) var unitOfWork: UnitOfWork
    
    private(set) var availableNotes: [ListNote] = []
    private(set) var filteredNotes: [ListNote] = []
    
    var isSearching: Bool = false
   
    
    init() {
        repository = .init(context: context)
        unitOfWork = UnitOfWork(context: context)
        retrieveNotes()
    }
    
    func note(for index: Int) -> ListNote {
        return isSearching ? filteredNotes[index] : availableNotes[index]
    }
    
    func noteCount() -> Int {
        isSearching ? filteredNotes.count : availableNotes.count
    }
    
    func setFilterNotes(for filter: String) {
        guard filter != "" && !filter.isEmpty else {
            filteredNotes = availableNotes
            return
        }
        filteredNotes = availableNotes.filter { $0.title.lowercased().contains(filter.lowercased()) || $0.descr.lowercased().contains(filter.lowercased()) }
    }
}

// MARK: - Function for SecretNote
extension NoteVM {
    func retrieveSecret(for id: UUID, _ completed: @escaping (ListNote?) -> Void) {
        let retrieveSecret = repository.getNotes(predicate: NSPredicate(format: "id == %@", id as CVarArg))
        switch retrieveSecret {
        case .success(let notes):
            guard let first = notes.first else {
                completed(nil)
                return
            }
            completed(first)
        case .failure( _): completed(nil)
        }
    }
}

// MARK: - Core Data for Original Note
extension NoteVM {
    func retrieveNotes() {
        let retrieveNotes = repository.getNotes(predicate: .none)
        switch retrieveNotes {
        case .success(let notes):
            availableNotes = notes
            filteredNotes = notes
        case .failure(let error):
            print("\(error)")
        }
    }
    
    func refreshNotes(completed: @escaping () -> Void) {
        let retrieveNotes = repository.getNotes(predicate: .none)
        switch retrieveNotes {
        case .success(let notes):
            availableNotes = notes
            filteredNotes = notes
            completed()
        case .failure(let error):
            print("\(error)")
            completed()
        }
    }
    
    func save(note: ListNote) {
        unitOfWork.noteRepository.create(note: note)
        unitOfWork.saveChanges()
        retrieveNotes()
    }
    
    func delete(note: ListNote) {
        unitOfWork.noteRepository.delete(note: note)
        unitOfWork.saveChanges()
        NotificationCenter.default.post(name: .noteDeleted, object: .none)
    }
    
    func update(note: ListNote) {
        unitOfWork.noteRepository.update(note: note)
        unitOfWork.saveChanges()
        NotificationCenter.default.post(name: .noteEdited, object: note)
    }
}
