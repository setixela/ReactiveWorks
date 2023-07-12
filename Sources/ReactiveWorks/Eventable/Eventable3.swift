//
//  Eventable3.swift
//  
//
//  Created by Aleksandr Solovyev on 12.07.2023.
//

import Foundation

public protocol Eventable3: Eventable {
   associatedtype Events3: InitProtocol

   typealias Key3<T> = KeyPath<Events3, T?>

   var events3: EventsStore { get set }
}

public extension Eventable3 {
   @discardableResult func on<T>(_ eventKey: Key3<T>, _ closure: @escaping Event<T>) -> Self {
      let hash = eventKey.hashValue
      let lambda = Lambda(lambda: closure)
      events3[hash] = lambda
      return self
   }

   @discardableResult
   func on<S: AnyObject>(_ eventKey: Key3<Void>, _ slf: S?, _ closure: @escaping (S) -> Void) -> Self {
      let hash = eventKey.hashValue
      let clos = { [weak slf] in
         guard let slf = slf else { return }
         closure(slf)
      }
      let lambda = Lambda(lambda: clos)
      events3[hash] = lambda
      return self
   }

   @discardableResult
   func on<T, S: AnyObject>(_ eventKey: Key3<T>, _ slf: S?, _ closure: @escaping (S, T) -> Void) -> Self {
      let hash = eventKey.hashValue
      let clos = { [weak slf] (value: T) in
         guard let slf = slf else { return }
         closure(slf, value)
      }
      let lambda = Lambda(lambda: clos)
      events3[hash] = lambda
      return self
   }

   @discardableResult
   func send(_ eventKey: Key3<Void>) -> Self {
      let hash = eventKey.hashValue
      guard
         let lambda = events3[hash]
      else {
         return self
      }

      lambda?.perform(())

      return self
   }

   @discardableResult
   func send<T>(_ eventKey: Key3<T>, _ payload: T) -> Self {
      let hash = eventKey.hashValue
      guard
         let lambda = events3[hash]
      else {
         return self
      }

      lambda?.perform(payload)

      return self
   }

   func hasSubcriberForEvent<T>(_ eventKey: Key3<T>) -> Bool {
      events3[eventKey.hashValue] != nil
   }

   @discardableResult
   func unSubscribe<T>(_ eventKey: Key3<T>) -> Bool {
      guard events3[eventKey.hashValue] != nil else { return false }

      events3[eventKey.hashValue] = nil
      return true
   }
}
