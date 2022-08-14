//
//  File.swift
//
//
//  Created by Aleksandr Solovyev on 04.08.2022.
//

import Foundation

// MARK: - Stateable

public protocol Stateable: InitProtocol {
   associatedtype State

   func applyState(_ state: State)
}

extension Stateable {
   public func applyState(_ state: State) {
      fatalError()
   }
}

extension Stateable2 {
   public func applyState(_ state: State2) {
      fatalError()
   }
}

public extension Stateable {
   init(_ states: State...) {
      self.init(states)
   }

   init(_ states: [State]) {
      self.init()

      states.forEach { applyState($0) }
   }

   @discardableResult
   func set(_ state: State) -> Self {
      applyState(state)

      return self
   }

   @discardableResult
   func set(_ states: [State]) -> Self {
      states.forEach { applyState($0) }

      return self
   }

   @discardableResult
   func set(_ states: State...) -> Self {
      states.forEach { applyState($0) }

      return self
   }
}

public protocol Stateable2: Stateable {
   associatedtype State2

   func applyState(_ state: State2)
}

public extension Stateable2 {
   @discardableResult
   func set(_ state: State2) -> Self {
      applyState(state)

      return self
   }

   @discardableResult
   func set(_ state: [State2]) -> Self {
      state.forEach { applyState($0) }

      return self
   }

   @discardableResult
   func set(_ states: State2...) -> Self {
      states.forEach { applyState($0) }

      return self
   }
}

// protocol Stateable2: Stateable2 {
//    associatedtype State3
//
//    func applyState(_ state: State3)
// }
//
// protocol Stateable4: Stateable2 {
//    associatedtype State4
//
//    func applyState(_ state: State4)
// }
//
// protocol Stateable5: Stateable4 {
//    associatedtype State5
//
//    func applyState(_ state: State5)
// }
