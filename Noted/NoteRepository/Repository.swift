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
    
    //The entity managed by the repository
    associatedtype Entity

    //Get a array of entities; The predicate to be used for fetching the entities;
    //The sort descriptors used for sorting the returned array of entities.
    func get(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> Result<[Entity], Error>
    
    // Creates an entity.
    func create() -> Result<Entity, Error>
    
    // Deletes an entity.
    func delete(entity: Entity) -> Result<Bool, Error>
}

//Enum for CoreData related errors
enum CoreDataError: Error {
    case generic(message: String)
    case invalidManagedObjectType
    case unableToDelete
}

//Generic class for handling NSManagedObject subclasses
class CoreDataRepository<T: NSManagedObject>: Repository {
    typealias Entity = T
    
        //The NSManagedObjectContext instance to be used for performing the operations.
        private let managedObjectContext: NSManagedObjectContext
    
    //The NSManagedObjectContext instance to be used for performing the operations
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    //Get array of NSManagedObject entities. Parameters: preidicate to be used to fetch the entities and sortDescriptors used for sorting the returned array of entities
    //Returns a result consisting of either an array of NSManagedObject entities or an Error
    func get(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> Result<[Entity], Error> {
        let fetchRequest = Entity.fetchRequest() //create fetch request for associated NSManagedObjectContext type
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        do {
            //perform fetch request
            if let fetchResults = try managedObjectContext.fetch(fetchRequest) as? [Entity] {
                return .success(fetchResults)
            } else {
                return .failure(CoreDataError.invalidManagedObjectType)
            }
        } catch {
            return .failure(error)
        }
    }
    
    //Creates a NSManagedObject entity
    //Returns a result consisting of either a NSManagedObject entity or an Error
    func create() -> Result<Entity, Error> {
        let className = String(describing: Entity.self)
        guard let managedObject = NSEntityDescription.insertNewObject(forEntityName: className, into: managedObjectContext) as? Entity else {
            return .failure(CoreDataError.invalidManagedObjectType)
        }
        return .success(managedObject)
    }
    
    //Deletes a NSManagedObject entity
    //Parameter entity: The NSManagedObject to be deleted
    //Returns a result consisting of either a Bool set to true or an Error
    @discardableResult
    func delete(entity: Entity) -> Result<Bool, Error> {
        managedObjectContext.delete(entity)
        return .success(true)
    }
}

//Protocol that describes a note repository
//Get a note using a predicate; create, update, delete a note on the persistence layer
protocol NoteRepositoryInterface {
    func getNotes(predicate: NSPredicate?) -> Result<[ListNote], Error>
    func create(note: ListNote) -> Result<Bool, CoreDataError>
    func update(note: ListNote) -> Result<Bool, CoreDataError>
    func delete(note: ListNote) -> Result<Bool, CoreDataError>
}
//Transform a persistence model to a domain model
protocol DomainModel {
    associatedtype DomainModelType
    func toDomainModel() -> DomainModelType
}

//Facilitate the creation of a Note Model
extension NoteMO: DomainModel {
    func toDomainModel() -> ListNote {
        return ListNote(id: id ?? .init(),
                        title: title ?? "",
                        descr: descr ?? "",
                        date: date ?? Date(),
                        secret: secret ?? "",
                        secretHidden: secretHidden,
                        color: color ?? .blue)
    }
}

extension NoteMO {
    var color: UIColor? {
        get {
            guard let hex = colorAsHex else { return nil }
            return UIColor(hex: hex)
        }
        set(newColor) {
            if let newColor = newColor {
                colorAsHex = newColor.toHex
            }
        }
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
            noteMO.secret = note.secret
            noteMO.secretHidden = note.secretHidden
            noteMO.colorAsHex = note.color.toHex
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
                firstNote.title = note.title
                firstNote.descr = note.descr
                firstNote.date = note.date
                firstNote.secret = note.secret
                firstNote.secretHidden = note.secretHidden
                firstNote.colorAsHex = note.color.toHex
                
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
