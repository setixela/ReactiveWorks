//
//  Communicable.swift
//  TeamForce
//
//  Created by Aleksandr Solovyev on 17.06.2022.
//

import Foundation

// MARK: - KeyPath setable

public protocol KeyPathSetable {}

public extension KeyPathSetable {
   @discardableResult func set<T>(_ keypath: WritableKeyPath<Self, T>, _ value: T) -> Self {
      var slf = self
      slf[keyPath: keypath] = value
      return self
   }

   func get<T>(_ keypath: KeyPath<Self, T>, _ value: T) -> T {
      self[keyPath: keypath]
   }
}

// MARK: - Communicable

public protocol Communicable: AnyObject {
   associatedtype Events: InitProtocol

   var eventsStore: Events { get set }
}

public extension Communicable {
   //
   @discardableResult
   func sendEvent<T>(_ event: KeyPath<Events, Event<T>?>, payload: T) -> Self {
      guard
         let lambda = eventsStore[keyPath: event]
      else {
         print("Event KeyPath did not observed!:\n   \(event)\n   Value: \(payload)")
         return self
      }

      DispatchQueue.main.async {
         lambda(payload)
      }

      return self
   }

   @discardableResult
   func sendEvent<T>(_ event: KeyPath<Events, Event<T>?>, _ payload: T) -> Self {
      return sendEvent(event, payload: payload)
   }

   @discardableResult
   func sendEvent(_ event: KeyPath<Events, Event<Void>?>) -> Self {
      guard
         let lambda = eventsStore[keyPath: event]
      else {
         print("Void Event KeyPath did not observed!:\n   \(event) ")
         return self
      }

      DispatchQueue.main.async {
         lambda(())
      }

      return self
   }

   @discardableResult
   func onEvent<T>(_ event: WritableKeyPath<Events, Event<T>?>, _ lambda: @escaping Event<T>) -> Self {
      eventsStore[keyPath: event] = lambda
      return self
   }

   @discardableResult
   func onEvent<T>(_ event: WritableKeyPath<Events, Event<T>?>) -> Work<Void, T> {
      let work = Work<Void, T>()
      //
      let lambda: Event<T> = { value in
         work.success(result: value)
         print("\n### WORK     \(work)\n")
      }
      //
      eventsStore[keyPath: event] = lambda
      return work
   }
}
