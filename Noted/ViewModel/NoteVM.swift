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
    
    private(set) var availableNotes: [ListNote] = []
    private(set) var unitOfWork: UnitOfWork
    
    init() {
        repository = .init(context: context)
        unitOfWork = UnitOfWork(context: context)
        retrieveNotes()
    }
    
    func note(for index: Int) -> ListNote {
        return availableNotes[index]
    }
    
    func noteCount() -> Int {
        availableNotes.count
    }
}

// MARK: - Core Data
extension NoteVM {
    func retrieveNotes() {
        let retrieveNotes = repository.getNotes(predicate: .none)
        switch retrieveNotes {
        case .success(let notes):
            availableNotes = notes
        case .failure(let error):
            print("\(error)")
        }
    }
    
    func refreshNotes(completed: @escaping () -> Void) {
        let retrieveNotes = repository.getNotes(predicate: .none)
        switch retrieveNotes {
        case .success(let notes):
            availableNotes = notes
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
        NotificationCenter.default.post(name: .noteEdited, object: .none)
    }
}
