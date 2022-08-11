//
//  Interactor.swift
//  TeamForce
//
//  Created by Aleksandr Solovyev on 11.08.2022.
//

import Foundation

public protocol InteractorEvents: InitProtocol {
   associatedtype Input: InitProtocol
   associatedtype Output: InitProtocol
   associatedtype Failure: InitProtocol

   var inputs: Input { get set }
   var outputs: Output { get set }
   var failures: Failure { get set }
}

public protocol Interactor: AnyObject {
   associatedtype IE: InteractorEvents

   var interacts: IE { get set }

   func start()
}

// subsribe
public extension Interactor {
   @discardableResult
   func onInput<T>(_ keypath: WritableKeyPath<IE.Input, Event<T>?>, _ block: Event<T>?) -> Self {
      interacts.inputs[keyPath: keypath] = block
      return self
   }

   @discardableResult
   func onInput<T>(_ event: WritableKeyPath<IE.Input, Event<T>?>) -> Work<Void, T> {
      let work = Work<Void, T>()
      let lambda: Event<T> = { value in
         work.success(result: value)
      }
      interacts.inputs[keyPath: event] = lambda
      return work
   }

   @discardableResult
   func onOutput<T>(_ keypath: WritableKeyPath<IE.Output, Event<T>?>, _ block: Event<T>?) -> Self {
      interacts.outputs[keyPath: keypath] = block
      return self
   }

   @discardableResult
   func onOutput<T>(_ event: WritableKeyPath<IE.Output, Event<T>?>) -> Work<Void, T> {
      let work = Work<Void, T>()
      let lambda: Event<T> = { value in
         work.success(result: value)
      }
      interacts.outputs[keyPath: event] = lambda
      return work
   }

   @discardableResult
   func onFailure<T>(_ keypath: WritableKeyPath<IE.Failure, Event<T>?>, _ block: Event<T>?) -> Self {
      interacts.failures[keyPath: keypath] = block
      return self
   }

   @discardableResult
   func onFailure<T>(_ event: WritableKeyPath<IE.Failure, Event<T>?>) -> Work<Void, T> {
      let work = Work<Void, T>()
      let lambda: Event<T> = { value in
         work.success(result: value)
      }
      interacts.failures[keyPath: event] = lambda
      return work
   }
}

// send
public extension Interactor {
   @discardableResult
   func sendInput<T>(_ keypath: KeyPath<IE.Input, Event<T>?>, payload: T) -> Self {
      guard
         let lambda = interacts.inputs[keyPath: keypath]
      else {
         print("KeyPath did not observed!:\n \(keypath)\n Value: \(payload)")
         return self
      }

      DispatchQueue.main.async {
         lambda(payload)
      }

      return self
   }

   @discardableResult
   func sendOutput<T>(_ keypath: KeyPath<IE.Output, Event<T>?>, payload: T) -> Self {
      guard
         let lambda = interacts.outputs[keyPath: keypath]
      else {
         print("KeyPath did not observed!:\n \(keypath)\n Value: \(payload)")
         return self
      }

      DispatchQueue.main.async {
         lambda(payload)
      }

      return self
   }

   @discardableResult
   func sendError<T>(_ keypath: KeyPath<IE.Failure, Event<T>?>, payload: T) -> Self {
      guard
         let lambda = interacts.failures[keyPath: keypath]
      else {
         print("KeyPath did not observed!:\n \(keypath)\n Value: \(payload)")
         return self
      }

      DispatchQueue.main.async {
         lambda(payload)
      }

      return self
   }
}

public protocol Interactable {
   associatedtype Business: Interactor

   var business: Business { get }
}
