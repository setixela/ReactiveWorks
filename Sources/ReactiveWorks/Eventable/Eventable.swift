//
//  File.swift
//  
//
//  Created by Aleksandr Solovyev on 01.09.2022.
//

import Foundation

// MARK: - Reinventing Eventable

public protocol Eventable: AnyObject {
   associatedtype Events: InitProtocol

   typealias Key<T> = KeyPath<Events, T?>

   var events: [Int: LambdaProtocol?] { get set }
}

public extension Eventable {
   @discardableResult
   func on<T>(_ eventKey: Key<T>, _ closure: @escaping Event<T>) -> Self {
      let hash = eventKey.hashValue
      log(hash)
      let lambda = Lambda(lambda: closure)
      events[hash] = lambda
      return self
   }

   @discardableResult
   func on<T>(_ eventKey: Key<T>) -> Work<Void, T> {
      let hash = eventKey.hashValue
      log(hash)
      let work = Work<Void, T>()
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
      log(hash)
      guard
         let lambda = events[hash]!
      else {
         return self
      }

      DispatchQueue.main.async {
         lambda.perform(())
      }

      return self
   }

   @discardableResult
   func send<T>(_ eventKey: Key<T>, _ payload: T) -> Self {
      let hash = eventKey.hashValue
      log(hash)
      guard
         let lambda = events[hash]!
      else {
         return self
      }

      DispatchQueue.main.async {
         lambda.perform(payload)
      }

      return self
   }
}
