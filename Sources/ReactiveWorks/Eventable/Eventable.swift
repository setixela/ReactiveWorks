//
//  File.swift
//  
//
//  Created by Aleksandr Solovyev on 01.09.2022.
//

import Foundation

// MARK: - Reinventing Eventable

public typealias EventsStore = [Int: LambdaProtocol?]

public protocol Eventable: AnyObject {
   associatedtype Events: InitProtocol

   typealias Key<T> = KeyPath<Events, T?>

   var events: EventsStore { get set }
}

public extension Eventable {
   @discardableResult
   func on<T>(_ eventKey: Key<T>, _ closure: @escaping Event<T>) -> Self {
      let hash = eventKey.hashValue
      let lambda = Lambda(lambda: closure)
      events[hash] = lambda
      return self
   }

   @discardableResult
   func on<S: AnyObject>( _ eventKey: Key<Void>, weak slf: S, _ closure: @escaping (S) -> Void) -> Self {
      let hash = eventKey.hashValue
      let clos = { [weak slf] in
         guard let slf = slf else { return }
         closure(slf)
      }
      let lambda = Lambda(lambda: clos)
      events[hash] = lambda
      return self
   }

   @discardableResult
   func on<T,S: AnyObject>(_ eventKey: Key<T>, weak slf: S, _ closure: @escaping (S,T) -> Void) -> Self {
      let hash = eventKey.hashValue
      let clos = { [weak slf] (value: T) in
         guard let slf = slf else { return }
         closure(slf, value)
      }
      let lambda = Lambda(lambda: clos)
      events[hash] = lambda
      return self
   }

   @discardableResult
   func on<T>(_ eventKey: Key<T>) -> Work<Void, T> {
      let hash = eventKey.hashValue
      let work = Work<Void, T>()
      work.type = .event
      //
      let closure: Event<T> = { value in
         work.success(result: value)
      }
      //
      events[hash] = Lambda(lambda: closure)

      return work
   }

   @discardableResult
   func send(_ eventKey: Key<Void>) -> Self{
      let hash = eventKey.hashValue
      guard
         let lambda = events[hash]
      else {
         return self
      }

      DispatchQueue.main.async {
         lambda?.perform(())
      }

      return self
   }

   @discardableResult
   func send<T>(_ eventKey: Key<T>, _ payload: T) -> Self {
      let hash = eventKey.hashValue
      guard
         let lambda = events[hash]
      else {
         return self
      }

      DispatchQueue.main.async {
         lambda?.perform(payload)
      }

      return self
   }
}
