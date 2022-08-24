//
//  NoteRepository.swift
//  Noted
//
//  Created by Stephanie Liew on 8/9/22.
//

import Foundation
import CoreData
import UIKit

protocol Repository {
    
    associatedtype Entity

    //  - predicate: The predicate to be used for fetching the entities.
    //   - sortDescriptors: The sort descriptors used for sorting the returned array of entities.
    func get(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> Result<[Entity], Error>
    
    // Creates an entity.
    func create() -> Result<Entity, Error>
    
    // Deletes an entity.
    func delete(entity: Entity) -> Result<Bool, Error>
}

enum CoreDataError: Error {
    case generic(message: String)
    case invalidManagedObjectType
    case unableToDelete
}

// Generic class for handling NSManagedObject subclasses
class CoreDataRepository<T: NSManagedObject>: Repository {
    typealias Entity = T
    
    // The NSManagedObjectContext instance to be used for performing the operations.
        private let managedObjectContext: NSManagedObjectContext
    
    //The NSManagedObjectContext instance to be used for performing the operations
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    func get(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> Result<[Entity], Error> {
        let fetchRequest = Entity.fetchRequest()
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        do {
            if let fetchResults = try managedObjectContext.fetch(fetchRequest) as? [Entity] {
                return .success(fetchResults)
            } else {
                return .failure(CoreDataError.invalidManagedObjectType)
            }
        } catch {
            return .failure(error)
        }
    }
    
    func create() -> Result<Entity, Error> {
        let className = String(describing: Entity.self)
        guard let managedObject = NSEntityDescription.insertNewObject(forEntityName: className, into: managedObjectContext) as? Entity else {
            return .failure(CoreDataError.invalidManagedObjectType)
        }
        return .success(managedObject)
    }
    
    @discardableResult
    func delete(entity: Entity) -> Result<Bool, Error> {
        managedObjectContext.delete(entity)
        return .success(true)
    }
}

protocol NoteRepositoryInterface {
    func getNotes(predicate: NSPredicate?) -> Result<[ListNote], Error>
    func create(note: ListNote) -> Result<Bool, CoreDataError>
    func update(note: ListNote) -> Result<Bool, CoreDataError>
    func delete(note: ListNote) -> Result<Bool, CoreDataError>
}

protocol DomainModel {
    associatedtype DomainModelType
    func toDomainModel() -> DomainModelType
}

extension NoteMO: DomainModel {
    func toDomainModel() -> ListNote {
        return ListNote(id: id ?? .init(), title: title ?? "", descr: descr ?? "", date: date ?? Date())
        
    }
}

class NoteRepository {
    private let repository: CoreDataRepository<NoteMO>
    //context: storing and requesting core data
    init(context: NSManagedObjectContext) {
        self.repository = CoreDataRepository<NoteMO>(managedObjectContext: context)
    }
}

// MARK - NoteRepository
extension NoteRepository: NoteRepositoryInterface {
    //gets note using predicate
    @discardableResult
    func getNotes(predicate: NSPredicate?) -> Result<[ListNote], Error> {
        let result = repository.get(predicate: predicate, sortDescriptors: nil)
        switch result {
        case .success(let notesMO):
            let notes = notesMO.map {noteMO -> ListNote in
                return noteMO.toDomainModel()}
            
            return .success(notes)
        case .failure(let error):
            return .failure(error)
        }
    } //creates a note on persistance layer
    @discardableResult
    func create(note: ListNote) -> Result<Bool, CoreDataError> {
        let result = repository.create()
        switch result {
        case .success(let noteMO):
            noteMO.id = note.id
            noteMO.title = note.title
            noteMO.descr = note.descr
            noteMO.date = note.date
            return .success(true)
            
        case .failure(let error):
            return .failure(.generic(message: error.localizedDescription))
        }
    }
    @discardableResult
    func update(note: ListNote) -> Result<Bool, CoreDataError> {
        let result = repository.get(predicate: NSPredicate(format: "id == %@", note.id as CVarArg), sortDescriptors: .none)
        switch result {
        case .success(let notes):
            if let firstNote = notes.first {
                // Update
                firstNote.title = note.title
                firstNote.descr = note.descr
                firstNote.date = note.date
                
                return .success(true)
            } else {
                return .failure(.generic(message: "Unable to access first note to be updated"))
            }
        case .failure(let error):
            return .failure(.generic(message: error.localizedDescription))
        }
    }

    @discardableResult
    func delete(note: ListNote) -> Result<Bool, CoreDataError> {
        let result = repository.get(predicate: NSPredicate(format: "id == %@", note.id as CVarArg), sortDescriptors: .none)
        switch result {
        case .success(let notes):
            if let firstNote = notes.first {
                // Delete
                repository.delete(entity: firstNote)
                return .success(true)
            } else {
                return .failure(.generic(message: "Unable to access first note to be deleted"))
            }
        case .failure(let error):
            return .failure(.generic(message: error.localizedDescription))
        }
    }
}

// MARK: - UnitofWork
class UnitOfWork {
    
    private let context: NSManagedObjectContext
    let noteRepository: NoteRepository
    
    init (context: NSManagedObjectContext) {
        self.context = context
        self.noteRepository = NoteRepository(context: context)
    }
    
    @discardableResult func saveChanges() -> Result<Bool, Error> {
        do {
            try context.save()
            return .success(true)
        } catch {
            context.rollback()
            return .failure(error)
        }
    }
}
